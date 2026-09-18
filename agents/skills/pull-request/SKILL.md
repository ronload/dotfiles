---
name: pull-request
description: Review the commits on the current branch, draft a pull request title and description, and open the pull request with gh. Use when the user asks to open, create or raise a PR, or to push the branch and turn it into a pull request. Do not use for reviewing, editing or merging a pull request that already exists, or for summarizing a branch in chat.
license: MIT
compatibility: Requires git and the GitHub CLI (gh)
allowed-tools: >-
  Bash(git push -u origin *)
  Bash(git push origin *)
  Bash(gh pr create *)
  Bash(gh pr edit *)
  Bash(git log *)
  Bash(git diff *)
  Bash(git status *)
  Bash(git branch --list *)
  Bash(git branch -a *)
  Bash(git branch -v *)
  Bash(git branch --show-current)
  Bash(git remote -v *)
  Bash(git rev-parse *)
  Bash(gh pr list *)
  Bash(gh pr view *)
  Bash(gh pr diff *)
  Bash(gh label list *)
  Bash(gh repo view *)
---

- Review all commits on the current branch relative to the base branch (`git log` and `git diff` against main or the appropriate base).
- Assess whether the changes form a coherent, reviewable unit. If not, mention it.
- If the branch has not been pushed, push it first.
- Generate a concise PR title (under 70 characters) and a description that explains **why** the changes were made, not just what was changed.
- Do not hardcode a description template; adapt the format to the scope of the changes.
- Use `gh pr create` to create the PR.
- Add suitable labels to the PR.
- Never mention Claude, AI, or any AI assistant in the title or description.
- After drafting the title and description, ALWAYS ask the user for confirmation before creating the PR.
- NEVER create the PR directly, even when the environment approves tool calls without prompting.
