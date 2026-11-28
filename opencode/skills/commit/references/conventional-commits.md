# Conventional Commits (v1.0.0)

Format:

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

## type (required)

Determines the nature of the change. Common types:

- `feat`: a new feature (correlates with MINOR in SemVer)
- `fix`: a bug fix (correlates with PATCH in SemVer)
- `docs`: documentation only
- `style`: formatting, whitespace, semicolons; no logic change
- `refactor`: code restructuring with no behavior change
- `perf`: performance improvement
- `test`: adding or correcting tests
- `build`: build system or external dependency changes
- `ci`: CI configuration changes
- `chore`: maintenance tasks that don't modify src or test

## scope (optional)

A noun in parentheses describing the section of the codebase affected, e.g., `feat(auth)`, `fix(parser)`.

## description (required)

- Immediately follows the colon and space after type/scope.
- Written in English, lowercase, imperative mood.
- No period at the end.
- Concise: aim for under 50 characters, hard limit 72.

## body (optional)

- Separated from the subject by a blank line.
- Explains **why** the change was made, not what was changed.
- Free-form, may consist of multiple paragraphs.

## footer (optional)

- Separated from the body by a blank line.
- Format: `Token: value` or `Token #value`.
- Use `-` instead of spaces in multi-word tokens (e.g., `Reviewed-by: Name`).

## breaking change

- Append `!` immediately before the colon in the subject to indicate a breaking change (correlates with MAJOR in SemVer).
- Alternatively, add a `BREAKING CHANGE: <description>` footer (must be uppercase).
