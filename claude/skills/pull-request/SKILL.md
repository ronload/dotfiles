---
description: Review branch commits, generate a PR title and description, and create a pull request via gh.
argument-hint: optional context about the pull request
allowed-tools:
  - Bash(git *)
  - Bash(gh *)
---

Review all commits on the current branch relative to the base branch (`git log` and `git diff` against main or the appropriate base).
Assess whether the changes form a coherent, reviewable unit. If not, mention it.
If the branch has not been pushed, push it first.
Generate a concise PR title (under 70 characters) and a description that explains **why** the changes were made, not just what was changed.
Do not hardcode a description template; adapt the format to the scope of the changes.
Use `gh pr create` to create the PR.
Never mention Claude, AI, or any AI assistant in the title or description.
After drafting the title and description, ALWAYS ask for my confirmation before creating the PR.
NEVER create the PR directly, even in auto-accept mode.
