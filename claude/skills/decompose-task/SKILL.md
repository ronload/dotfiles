---
name: decompose-task
description: >
  Decompose a large phase, cycle, milestone, or epic into a set of small,
  actionable issues that can each be completed in a single Claude Code session.
  Use this skill whenever the user says things like "break this down",
  "拆 issue", "decompose this phase", "create issues for this milestone",
  "把這個大任務拆成小的", "plan this cycle", or references breaking work into
  subtasks, tickets, or stories. Also trigger when the user provides a SPEC.md,
  PRD, or feature description and asks to generate implementation tasks from it.
  If Linear MCP is connected, this skill can create issues directly in Linear.
---

# Decompose Task

Break a phase/cycle/epic into small, well-scoped issues that each fit in one
Claude Code session (~30 min focused work, ≤300 lines changed).

## When to Use

- User has a large feature, milestone, or phase to implement
- User provides a spec/PRD and wants implementation issues
- User wants to plan a cycle or sprint with concrete tasks

## Workflow

### Step 1 — Gather Context

Before decomposing, read the relevant context:

1. **Read the spec** — If user references a file (SPEC.md, PRD, design doc),
   read it first.
2. **Read the codebase** — Glob and grep to understand current architecture,
   existing patterns, and integration points.
3. **Identify boundaries** — Find module boundaries, API surfaces, and data
   models that naturally partition the work.

```
# Example discovery
glob src/**/*.go
grep -r "func New" src/ --include="*.go" -l
cat go.mod
```

### Step 2 — Decompose with Constraints

Apply these rules when splitting work:

#### Sizing Rules

| Rule                  | Guideline                                                    |
| --------------------- | ------------------------------------------------------------ |
| **Max scope**         | Each issue should be completable in one CC session (~30 min) |
| **Max file touch**    | ≤5 files modified per issue                                  |
| **Max lines changed** | ~300 lines (soft limit)                                      |
| **Single concern**    | One issue = one logical change                               |
| **Testable**          | Each issue has a clear "done" definition                     |

#### Decomposition Strategy

Use **vertical slicing** by default — each issue delivers a thin but
end-to-end slice of functionality (domain → repo → service → handler → test).

Fall back to **horizontal slicing** only when vertical slicing creates too many
cross-cutting dependencies (e.g., DB migration that multiple features need).

#### Ordering & Dependencies

- Identify the **critical path** — which issues block others
- Number issues in execution order
- Mark dependencies explicitly: `blocked-by: #N`
- Front-load foundational work: schema, interfaces, types
- Parallelize where possible: independent modules, tests

### Step 3 — Write Issues

Each issue follows this template:

```markdown
## Issue N: [Concise Title]

**Type:** feature | refactor | bugfix | chore | test
**Priority:** P0 (blocker) | P1 (must-have) | P2 (should-have) | P3 (nice-to-have)
**Estimate:** XS (<30min) | S (30min) | M (1hr) | L (2hr)
**Blocked by:** (issue numbers or "none")
**Labels:** [module/area tags]

### Context

Why this issue exists — 1-2 sentences linking to the parent goal.

### Task

Precise description of what to implement. Include:

- Which files to create/modify
- Key function signatures or interfaces
- Data models or schema changes

### Acceptance Criteria

- [ ] Criterion 1 (specific, verifiable)
- [ ] Criterion 2
- [ ] Tests pass: `go test ./path/to/...`

### Notes

Edge cases, gotchas, or references to related code.
```

### Step 4 — Output

**Default (Markdown):** Write all issues to a single file at
`docs/issues/<phase-name>.md` with a summary table at the top:

```markdown
# Phase: [Name]

## Summary

| #   | Title | Type | Est | Blocked by | Status |
| --- | ----- | ---- | --- | ---------- | ------ |
| 1   | ...   | ...  | ... | —          | 🔲     |
| 2   | ...   | ...  | ... | #1         | 🔲     |

---

## Issue 1: ...

...
```

**Linear (if MCP connected):** Ask the user if they want issues created in
Linear. If yes:

1. Confirm the target team and project
2. Create a parent issue for the phase
3. Create child issues with dependencies linked
4. Use labels matching the `[module/area]` tags

### Step 5 — Review Checklist

Before presenting to the user, self-verify:

- [ ] No issue touches >5 files
- [ ] No issue exceeds ~300 lines of change
- [ ] Every issue has clear acceptance criteria with a test command
- [ ] Dependencies form a DAG (no cycles)
- [ ] The first issue is unblocked and can start immediately
- [ ] Parallel tracks are identified and marked
- [ ] Total issues cover 100% of the phase scope — nothing missing
- [ ] Issue titles are unique and scannable

## Anti-Patterns to Avoid

- **"Implement feature X"** — Too vague. Break into specific code changes.
- **"Set up infrastructure"** — What infrastructure? Be specific.
- **Giant test issues** — Don't batch all tests into one issue; co-locate tests
  with the code they verify.
- **Implicit dependencies** — If issue 5 requires issue 3's types, say so.
- **Gold-plating** — P3 items go in a separate "future" section, not the main
  plan.

## Examples of Good vs Bad Issues

**Bad:**

> Issue: Add user authentication
>
> - Implement JWT auth, login, signup, password reset, session management

**Good:**

> Issue 1: Define User domain model and DB migration (XS)
> Issue 2: Implement POST /auth/register endpoint (S)
> Issue 3: Implement POST /auth/login with JWT token generation (S)
> Issue 4: Add JWT middleware for protected routes (S)
> Issue 5: Implement POST /auth/refresh token rotation (S)
> Issue 6: Write integration tests for auth flow (M)

## Adapting to the User's Stack

Read the project's tech stack from the codebase (go.mod, package.json,
Cargo.toml, etc.) and tailor:

- **Test commands** to the actual test runner
- **File paths** to the actual directory structure
- **Conventions** to what already exists in the codebase (e.g., if the project
  uses `module.go` + `routes.go` pattern, reflect that in issue file lists)
