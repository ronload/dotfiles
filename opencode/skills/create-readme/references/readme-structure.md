# README Structure

Target shape for a project README. Adapt it to the project; omit any section
the project does not need rather than filling it with padding.

## Section order

1. **Title and one-line description.** State what the project is and who it is
   for in a single sentence. No tagline that only makes sense once you already
   know the project.
2. **Badges.** Only ones that carry information a reader acts on: release
   version, build status, supported runtime versions, license. Skip vanity
   counters.
3. **Proof it works.** A screenshot, a short recording, or the smallest
   complete example that produces visible output. This comes before any prose
   about design or motivation.
4. **Why it exists.** Two or three sentences at most, and only when the
   problem is not obvious from the example above. Name the alternative the
   reader would otherwise reach for.
5. **Features.** A flat bulleted list. Each bullet names a capability the
   reader gets, not an implementation detail.
6. **Install.** The single most common installation path, as one copyable
   block. Put platform variants and building from source lower down.
7. **Usage.** Start with the shortest path to a working result, then add
   depth. Each step should be runnable as written without edits.
8. **Reference.** Options, flags, configuration keys, or API surface, as a
   table or definition list once there is more than a handful.
9. **Related work.** Links to the projects a reader might compare this one
   against, stated neutrally.

## Tone

- Address the reader as "you". Use active voice and the present tense.
- Lead every section with the outcome, then the mechanics.
- Drop marketing adjectives. "Fast", "simple" and "powerful" carry no
  information unless a number or comparison follows.
- Prefer showing over describing. A four-line example beats a paragraph.

## Length and density

- A reader should reach a working command within the first screen.
- Any section past roughly 40 lines belongs in its own file under `docs/`,
  linked from the README.
- Code blocks must be complete and runnable. Do not abbreviate with an ellipsis
  where a reader would need to guess what is missing.
- Every claim about behavior should be checkable against the repository. Do not
  document features the code does not have.
