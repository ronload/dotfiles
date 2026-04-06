---
description: Review staged and unstaged changes, then create atomic commits with Conventional Commits messages.
argument-hint: optional context about the changes
allowed-tools:
  # git read-only
  - Bash(git diff *)
  - Bash(git status *)
  - Bash(git log *)
  - Bash(git show *)
  - Bash(git blame *)
  - Bash(git branch --list *)
  - Bash(git branch -a *)
  - Bash(git branch -v *)
  - Bash(git tag -l *)
  - Bash(git stash list *)
  - Bash(git remote -v *)
  - Bash(git shortlog *)
  - Bash(git reflog *)
  - Bash(git ls-files *)
  - Bash(git rev-parse *)
  - Bash(git config --get *)
  # gh read-only
  - Bash(gh issue list *)
  - Bash(gh issue view *)
  - Bash(gh pr list *)
  - Bash(gh pr view *)
  - Bash(gh pr diff *)
  - Bash(gh run list *)
  - Bash(gh run view *)
  - Bash(gh search *)
  - Bash(gh api *)
  - Bash(gh repo view *)
  - Bash(gh release list *)
  - Bash(gh release view *)
---

Review both staged (`git diff --cached`) and unstaged (`git diff` and `git status`) changes to understand the full picture, then organize them into atomic commits.
If nothing is staged yet, group files by logical change, stage each group with `git add`, and commit separately.
Write a concise commit message following Conventional Commits format.
The subject line should be in English, lowercase, and without a period at the end.
For non-trivial changes, add a commit body explaining **why** the change was made, not what was changed.
Each commit should contain exactly one logical change.
Never mention Claude, AI, or any AI assistant in the commit message.
Proceed to execute `git add` and `git commit` directly — permission will be handled by the tool system.
