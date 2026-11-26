# Code quality review

Rules for the quality reviewers and quality validators of the pr-review skill. Read the shared sections, then the section for your facet. Validators also read "Validation".

You are judging the quality of the changed code, not hunting for bugs. Other reviewers cover correctness and rule files. `NO ISSUES` is a normal result. Do not pad.

## Rules for every quality reviewer

- Review your own facet only.
- Read the diff, then the code around it. Search `REVIEW_ROOT` before claiming that something exists, is unused, or is a convention.
- Report only what the change introduced. That includes code and comments the change made obsolete.
- Every issue needs three things: the concrete cost (what is duplicated, wasted, misleading, or harder to maintain), the concrete alternative, and the evidence your facet requires. If one is missing, do not report the issue.
- Anchor each issue on changed lines. When the same issue occurs in several places, report it once and list the other locations.

## Do not report

- Missing docstrings, type annotations, comments, or tests.
- Unused imports, formatting, or anything a linter, formatter, or type checker catches.
- Generic advice with no named cost, such as "extract this into a function".
- A fix that would change intended behavior.
- A fix that needs changes well outside the diff. The altitude and approach reviewers may report these as `fyi`.
- A fix that demands more rigor than the rest of the codebase shows.
- A preference with no basis in this codebase.
- Removing a comment that explains why the code is the way it is.
- Removing validation at a trust boundary, a security check, or protection against data loss.
- A pattern the repository already uses on purpose for the same situation.
- Anything the code explicitly waives, for example with a lint ignore comment or a comment that gives the reason.
- A violation of an explicit rule in a rule file. The rule reviewers cover those.

## Tiers

- `should-fix`: a maintainability problem serious enough to hold the merge. Examples: a block of logic copied verbatim, a reimplementation of a helper that already exists, an error swallowed so that a failure goes unseen, a comment that says the opposite of what the code does, expensive work repeated on a hot path, an old implementation or compatibility path kept when nothing depends on it anymore, a detour where a much simpler data flow reaches the same goal.
- `nit`: worth fixing, but it would not hold the merge.
- `fyi`: a design observation whose fix reaches well outside the diff. Only the altitude and approach reviewers use this tier.

When in doubt between two tiers, pick the lower one.

## Output format

Return either the single line `NO ISSUES` or one block per issue:

```text
ISSUE
title: <imperative, at most 80 characters>
tier: should-fix | nit | fyi
file: <path relative to REVIEW_ROOT>
lines: <start-end, as line numbers in HEAD_SHA; must overlap the diff; at most about 10 lines>
category: quality
facet: reuse | simplification | efficiency | altitude | consistency | comments | error-handling | naming | approach
description: <what is wrong, and its concrete cost>
alternative: <the concrete replacement>
evidence: <what your facet requires, with path:line references>
also: <other locations with the same issue, or "none">
END
```

## Facets

### reuse

Look for new code that reimplements a helper, utility, type, or constant the codebase already has, and for logic copied from elsewhere in the repository. Search shared and utility modules and the files next to the change.

- Evidence: the `path:line` of the existing code, and why it is equivalent here: same inputs, results, edge cases, and errors.
- Tier: `should-fix` for a reimplemented helper or a block copied verbatim. `nit` for a partial overlap.
- Skip it when the new code depends on behavior the existing code does not have.

### simplification

Look at the local shape of the code: state that is redundant or can be derived, copy-paste with slight variation inside the change, deep nesting where guard clauses would do, and intermediate variables or conversions that add nothing. Whether the whole approach is too complex, or whether an old path that is still wired in should stay, belongs to the approach reviewer.

Also look for leftovers: what the change made obsolete and left in place. This can be a function, type, file, setting, flag, test, or documentation section that nothing uses once the change is applied. For example, the change moves every caller to a new function and keeps the old one. Code on an unchanged line counts only when this change removed its last use. Anchor the issue on the changed lines that did so, and list the leftover under `also`. Deleting a leftover counts as part of this change, even when it sits in a file the change does not touch.

- Evidence: the simpler form in a few lines, and why it behaves the same. For a leftover, the search that shows nothing references it, and the changed lines that removed its last use.
- Tier: `should-fix` when the simpler form removes a copied block or state that must be kept in sync, or when the leftover is the old implementation of something the change replaced. Otherwise `nit`.

### efficiency

Look for wasted work: repeated I/O or queries, work inside a loop that could be done once, independent operations run one after another that could run concurrently, blocking work on startup or a hot path, and loading more data than is used.

- Evidence: the call path that shows the code runs repeatedly or on a hot path, and the cheaper alternative.
- Tier: `should-fix` when the waste grows with the size of the input or occurs on every request. Otherwise `nit`.
- Skip micro-optimizations and code that runs rarely.

### altitude

Check that the change is made at the right depth. Look for a special case added inside shared code, a fix at one call site when the cause sits in a shared function that other callers also use, a workaround for a symptom, and logic placed in a layer the codebase reserves for something else.

- Evidence: the shared code that received the special case, or the other callers with the same need, with `path:line`, and the place where the change belongs.
- Tier: `should-fix` or `nit` when the better placement stays within the files the change already touches. `fyi` when it reaches well outside the diff.

### consistency

Look for places where the change does something differently from how the codebase already does the same thing: error handling, data access, file layout, API shape, or a second library for a job an existing dependency already does.

- Evidence: at least two existing occurrences of the convention, with `path:line`, in code comparable to the changed code.
- Tier: `should-fix` when the change adds a second way to do something central, such as a duplicate dependency. Otherwise `nit`.
- Skip it when the codebase itself is mixed.

### comments

Look for comments and docstrings that the change added or made stale: a comment that contradicts the code, describes behavior the change removed, names something that no longer exists, or a TODO the change resolved. A comment on an unchanged line counts only when the change made it wrong. Never suggest adding a comment.

- Evidence: the comment and the code that contradicts it, with `path:line`.
- Tier: `should-fix` when the comment would mislead a caller or maintainer about what the code does. Otherwise `nit`.

### error-handling

Look for failures the change hides: an empty catch, a catch that logs and then continues as if the call succeeded, a fallback value that masks a failure, an error replaced by a generic one that loses the cause, and an ignored result or promise.

- Evidence: where the error is dropped, with `path:line`, and which failure becomes invisible or what the caller sees instead.
- Tier: `should-fix` when a real failure would go unnoticed. Otherwise `nit`.
- Skip best-effort cleanup, and ignores that the code explains. Do not ask for handling of states that cannot occur.

### naming

Look for names that mislead: a name that implies behavior the code does not have, a name the codebase already uses for something else, and a name that breaks the codebase's convention for that kind of thing. Also look for code that is hard to follow where a specific rewrite is clearly easier to read.

- Evidence: the gap between what the name implies and what the code does, or the existing convention with `path:line`.
- Tier: `nit` at most.
- Skip a choice between two equally clear names.

### approach

Check whether the change takes a longer route than the goal needs. Every line can be correct while the whole is a detour, so do not judge the change on its own terms.

You receive a `BASELINE` block: the simplest change another reviewer designed from the goal and the old code, without seeing this change. It is a reference, not the answer. Its author could not see requirements that are missing from the goal. Its `path:line` references point at the code before the change. Read them with `git show <BASE_SHA>:<path>`.

1. Trace the data flow of the actual change: where the data comes from, each step it passes through, and where it ends up.
2. For each intermediate step, ask what would break if it were removed.
3. List everything the change adds: types, files, state, settings, layers, dependencies. Match each one to a part of the goal or to a constraint in the code.
4. List what the change replaces: each function, name, format, or setting that now has a new counterpart. Check whether the old one is gone. If it is still there, search for what still depends on it.
5. Compare with the baseline. Where the change does more, or keeps something the baseline removes, look for the reason: a requirement, caller, or constraint the baseline missed. If you find one, the baseline is wrong there and there is no issue.

Signals of a detour:

- Data converted to another form and later converted back.
- Stored state that could be derived, plus code to keep it in sync.
- A layer that only passes data along.
- An interface, factory, event, or setting with a single implementation, caller, or value.
- A queue, cache, or state machine around a flow that a direct call would handle.
- A new path added beside an existing one instead of a change to the existing one.
- An old path kept beside its replacement: an alias or re-export of the old name, a wrapper that only forwards to the new code, a fallback for the old format, or a flag that switches the old behavior back on. This includes compatibility with a name or format that did not exist before the change.
- Flexibility for a need the goal does not state.

For each issue:

- Evidence: the simpler data flow step by step, what is deleted or inlined, and where the remaining logic lives; the number of callers or implementations found by searching; and why the simpler flow still meets the goal. For an old path kept beside its replacement, also the search for what still depends on it: callers, stored data in the old format, and users outside the repository.
- Tier: `should-fix` when the simpler flow removes a layer, a piece of state, a file, or an old path that nothing depends on, and stays within the files the change touches. `nit` for local ceremony. `fyi` when it would need rework well outside the diff.
- Skip flexibility that two or more real variants already use.
- Skip an old path that something real still depends on: a remaining caller, stored data in the old format, or an interface published to users outside the repository. Skip it too when the goal asks to keep the old behavior available.

## Validation

For quality validators. Confirm an issue only when its facts hold in `HEAD_SHA`. Check them yourself with the read and search tools. Do not rely on the reviewer's description.

For every issue, check that:

- The change introduced it, or made the code or comment obsolete.
- Nothing in "Do not report" applies.
- The alternative would not change intended behavior.
- The evidence the facet requires is present and correct.

Then check the facet. An issue can name several facets when reviewers agreed on the same fix. It is enough that the check for one of them holds.

- `reuse`: the existing code is at the cited location and gives the same results, edge cases, and errors for every input the new code handles.
- `simplification`: the simpler form behaves the same for every input the code can receive. For a leftover, nothing references it, including exports, tests, and dynamic lookups, and it was in use before the change.
- `efficiency`: the code is reached as often as claimed, and the alternative keeps any ordering or side effect the code depends on.
- `altitude`: the shared code and the other callers are as described, and moving the change would not break them.
- `consistency`: the cited occurrences exist and are comparable, and the style of the changed code is not also common in the codebase.
- `comments`: the comment and the code really disagree.
- `error-handling`: the error really is dropped, nothing further up handles or reports it, and the code gives no reason for ignoring it.
- `naming`: a reader would really be misled.
- `approach`: try to break the simpler flow. Look for a requirement, caller, or constraint it fails to meet. Count callers and implementations with a search. For an old path kept beside its replacement, look for anything that still depends on it, including stored data and users outside the repository. Check that the pattern is not one the repository uses on purpose for the same situation. Confirm only when you find no counterexample.

Set the final tier from "Tiers". Do not score importance with a number. Return:

```text
VERDICT: CONFIRMED | REJECTED
tier: <should-fix | nit | fyi, only when CONFIRMED>
evidence: <one or two sentences pointing at the code>
```
