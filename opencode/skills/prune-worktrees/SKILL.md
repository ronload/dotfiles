---
name: prune-worktrees
description: Survey every git worktree and local branch in the current repository, work out which ones are finished (merged into the base branch, including squash merges that git cannot see by ancestry) or stale, delete the finished ones that are safe to drop, and ask about the rest in one batch. Use when the user wants to clean up, prune, tidy, or delete worktrees or branches, asks which branches are already merged or no longer needed, or mentions leftover or abandoned worktrees, even when they name only one of the two. Do not use for removing a single worktree or branch the user has already named, for deleting remote branches, or for discarding uncommitted files.
license: MIT
compatibility: Requires git 2.38 or newer (git merge-tree --write-tree)
allowed-tools: >-
  Bash(git worktree list *)
  Bash(git worktree prune *)
  Bash(git worktree remove *)
  Bash(git branch -d *)
  Bash(git branch -D *)
  Bash(git branch --show-current)
  Bash(git branch -vv *)
  Bash(git for-each-ref *)
  Bash(git fetch --prune *)
  Bash(git merge-tree *)
  Bash(git merge-base *)
  Bash(git rev-parse *)
  Bash(git symbolic-ref *)
  Bash(git remote set-head *)
  Bash(git status *)
  Bash(git log *)
---

Find the worktrees and local branches whose job is done, remove the ones that are provably safe to drop, and ask about everything else in a single batch. A finished branch is cheap to recreate from the base branch; an unmerged commit or an uncommitted edit is not. Every step below exists to prove, before a deletion, that nothing unique would be lost.

Scope is local: worktrees, local branches, and stale remote-tracking refs. Leave remote branches alone, and do not run `git clean` or `git gc` or touch stashes.

## Preparation

Run everything from the main worktree. `git worktree list` prints it first, and `git rev-parse --git-common-dir` from anywhere locates its `.git`. The session may be running inside a linked worktree that turns out to be a candidate, and removing the directory under the session cannot be undone by the harness.

Resolve the base branch, the one finished work lands on:

1. `git symbolic-ref -q --short refs/remotes/origin/HEAD`, for example `origin/main`.
2. If that is unset, `git remote set-head origin --auto` and retry.
3. With no remote at all, use the local `main` or `master`, whichever exists.

Then `git fetch --prune`. A local `main` is often behind the server, and a squash merge made on GitHub exists only on `origin/main` until it is pulled, so comparing against a stale base would call recently merged branches unmerged. Compare against the remote-tracking ref whenever one exists. If the fetch fails (offline), continue with what is local and say so in the report.

## Survey

Collect every signal before classifying anything:

- `git worktree list --porcelain`: path, HEAD, branch, and the `detached`, `locked`, and `prunable` markers.
- `git -C <path> status --porcelain` for each linked worktree whose directory exists. Any output means dirty; ignored files do not count, which matches what `git worktree remove` tolerates.
- `git for-each-ref --sort=-committerdate --format='%(refname:short) %(committerdate:short) %(upstream:short) %(upstream:track)' refs/heads/`: every local branch with its last commit date and upstream state.
- `git rev-parse --show-toplevel` and `git branch --show-current` from the session's own directory, to know which worktree and branch the session occupies.

## Classify

A branch is merged when either test against the base ref passes:

- Ancestry: it is listed by `git for-each-ref --merged <base> --format='%(refname:short)' refs/heads/`. Covers merge commits and fast-forwards.
- Content: for every branch the ancestry test did not cover, `git merge-tree --write-tree <base> <branch>` exits 0 and prints the same id as `git rev-parse '<base>^{tree}'`. Merging the branch into base would change nothing, which is exactly what a squash or rebase merge leaves behind: the work is on base but the commits are not its ancestors. GitHub squash merges make this the normal case, so skipping the content test leaves most finished branches in place. A non-zero exit (conflicts) or a different tree means the branch still carries something base does not have.

```sh
base=origin/main
base_tree=$(git rev-parse "${base}^{tree}")
for b in $(git for-each-ref --no-merged "$base" --format='%(refname:short)' refs/heads/); do
  tree=$(git merge-tree --write-tree "$base" "$b" 2>/dev/null) && [ "$tree" = "$base_tree" ] && echo "$b"
done
```

Stale: not merged, and the last commit is older than 30 days, unless the user names another threshold.

Active: everything else.

Never a candidate, whatever the tests say:

- The base branch, and long-lived branches such as `develop`, `release/*`, `hotfix/*`.
- Locked worktrees. Someone locked them on purpose.
- The worktree the session is running in. Its branch can still be a candidate; the directory cannot.

## Decide

Delete without asking when a branch is merged and, if a worktree holds it, that worktree exists, is clean, and is not the session's. Also prune worktree entries whose directory is already gone (`prunable`); nothing is left there to lose. Pruning only drops the entry, so the branch it pointed at still goes through the normal classification.

Ask, in one message that lists every item with its evidence and a suggestion, about:

- Stale branches, with or without a worktree. Old does not mean finished. Removing the worktree but keeping the branch is a reasonable middle ground to offer.
- Merged branches whose worktree is dirty. The uncommitted changes may be scratch or may be the next piece of work.
- Branches whose upstream is `[gone]` but that neither merge test accepts. Often squash-merged after review edits were pushed from elsewhere, sometimes deleted remotely on purpose.
- Detached worktrees (no branch). Nothing says what they were for.
- A merged branch checked out in the main worktree. Deleting it means switching that worktree to base first.
- A merged branch whose worktree is the session's own. The session has to move out first (OpenCode: `session_move`), then rerun.

Number the items so the user can answer with numbers. Keep, and only mention in the summary: active branches and their worktrees, dirty or not, and everything in the never-a-candidate list.

## Execute

Order matters, because git refuses to delete a branch that a worktree has checked out:

1. `git worktree prune` to drop entries for missing directories.
2. `git worktree remove <path>` for each worktree to go. Add `--force` only for a dirty worktree the user explicitly approved; without it git refuses, which is the safety net working as intended. When the harness keeps its own worktree records (OpenCode's `worktree_list` and `worktree_remove`), remove the worktrees it lists through its tool so the records stay in sync; it follows the same contract, refusing a dirty worktree unless `force` is set.
3. `git branch -d <branch>` for ancestry-merged branches, so git's own check confirms. `git branch -D <branch>` for content-merged ones, since `-d` cannot see squash merges and would refuse; the merge-tree test already proved the content is on base.
4. Keep the `(was <sha>)` that each deletion prints. A deleted branch can be restored with `git branch <name> <sha>` while the object survives, so the report must carry it.

After the user answers the batch question, apply exactly the approved items the same way and extend the report. Anything not approved stays.

## Report

Use this structure:

```markdown
## Worktree and branch cleanup

Base: origin/main, fetched (or: fetch failed, compared against local main)

### Removed
- feat/x (was 414d799), worktree ../wt-x: squash-merged into main
- feat/y (was df7b0a6): merged into main
- pruned worktree entry ../wt-z (directory already gone)

### Needs your call
1. feat/stale, worktree ../wt-stale (clean): unmerged, last commit 2026-08-15 (73 days ago). Suggest delete.
2. feat/old, worktree ../wt-old has 3 uncommitted files: merged, but the edits would be lost. Suggest inspect first.

### Kept
- main (base), feat/active (last commit 2 days ago, unmerged), feat/conflict (unmerged, conflicts with main)
```
