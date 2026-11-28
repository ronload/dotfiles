---
name: commit
description: Review staged and unstaged changes, then create atomic commits with Conventional Commits messages. Use when the user asks to commit, to stage and commit, or to split the working tree into separate commits. Do not use when the user only wants to inspect what changed, wants a message drafted without committing anything, or is asking about commits that already exist.
license: MIT
compatibility: Requires git, and the GitHub CLI (gh) to read issue and PR context
allowed-tools: >-
  Bash(git add *)
  Bash(git commit *)
  Bash(git diff *)
  Bash(git status *)
  Bash(git log *)
  Bash(git show *)
  Bash(git blame *)
  Bash(git branch --list *)
  Bash(git branch -a *)
  Bash(git branch -v *)
  Bash(git tag -l *)
  Bash(git stash list *)
  Bash(git remote -v *)
  Bash(git shortlog *)
  Bash(git reflog *)
  Bash(git ls-files *)
  Bash(git rev-parse *)
  Bash(git config --get *)
  Bash(gh issue list *)
  Bash(gh issue view *)
  Bash(gh pr list *)
  Bash(gh pr view *)
  Bash(gh pr diff *)
  Bash(gh run list *)
  Bash(gh run view *)
  Bash(gh search *)
  Bash(gh api *)
  Bash(gh repo view *)
  Bash(gh release list *)
  Bash(gh release view *)
---

Review both staged (`git diff --cached`) and unstaged (`git diff` and `git status`) changes to understand the full picture, then organize them into atomic commits.
Never mention Claude, AI, or any AI assistant in the commit message.
Proceed to execute `git add` and `git commit` directly; permission is handled by the tool system.

## Atomic Commit

Each commit must be the smallest meaningful unit of work that can stand on its own.

- One logical change per commit. A bug fix, a new feature, a refactor: each is its own commit.
- Do not mix unrelated changes in a single commit (e.g., a bug fix + a formatting change = two separate commits).
- Do not mix refactoring with behavior changes.
- Formatting or whitespace-only changes must be in their own commit, separate from functional changes.
- When a single logical change touches multiple files, all those files belong in the same commit.
- If unstaged changes span multiple logical units, group related files together via `git add`, commit each group separately.
- Each commit must leave the codebase in a working state (builds successfully, tests pass).

## Commit Message

Messages follow Conventional Commits v1.0.0. Read `references/conventional-commits.md` for the format, the type list, and the breaking-change rules before writing the message.
