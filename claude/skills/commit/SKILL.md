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

Review both staged (`git diff --cached`) and unstaged (`git diff` and `git status`) changes to understand the full picture, then organize them into atomic commits following the two principles below.
Never mention Claude, AI, or any AI assistant in the commit message.
Proceed to execute `git add` and `git commit` directly -- permission will be handled by the tool system.

## Atomic Commit

Each commit must be the smallest meaningful unit of work that can stand on its own.

- One logical change per commit. A bug fix, a new feature, a refactor -- each is its own commit.
- Do not mix unrelated changes in a single commit (e.g., a bug fix + a formatting change = two separate commits).
- Do not mix refactoring with behavior changes.
- Formatting or whitespace-only changes must be in their own commit, separate from functional changes.
- When a single logical change touches multiple files, all those files belong in the same commit.
- If unstaged changes span multiple logical units, group related files together via `git add`, commit each group separately.
- Each commit must leave the codebase in a working state (builds successfully, tests pass).

## Conventional Commits (v1.0.0)

Format:

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

### type (required)

Determines the nature of the change. Common types:

- `feat` -- a new feature (correlates with MINOR in SemVer)
- `fix` -- a bug fix (correlates with PATCH in SemVer)
- `docs` -- documentation only
- `style` -- formatting, whitespace, semicolons; no logic change
- `refactor` -- code restructuring with no behavior change
- `perf` -- performance improvement
- `test` -- adding or correcting tests
- `build` -- build system or external dependency changes
- `ci` -- CI configuration changes
- `chore` -- maintenance tasks that don't modify src or test

### scope (optional)

A noun in parentheses describing the section of the codebase affected, e.g., `feat(auth)`, `fix(parser)`.

### description (required)

- Immediately follows the colon and space after type/scope.
- Written in English, lowercase, imperative mood.
- No period at the end.
- Concise: aim for under 50 characters, hard limit 72.

### body (optional)

- Separated from the subject by a blank line.
- Explains **why** the change was made, not what was changed.
- Free-form, may consist of multiple paragraphs.

### footer (optional)

- Separated from the body by a blank line.
- Format: `Token: value` or `Token #value`.
- Use `-` instead of spaces in multi-word tokens (e.g., `Reviewed-by: Name`).

### breaking change

- Append `!` immediately before the colon in the subject to indicate a breaking change (correlates with MAJOR in SemVer).
- Alternatively, add a `BREAKING CHANGE: <description>` footer (must be uppercase).
