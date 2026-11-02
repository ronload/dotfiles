---
name: find-docs
description: >-
  Retrieves up-to-date documentation, API references, and code examples for any
  developer technology. Use this skill whenever the user asks about a specific
  library, framework, SDK, CLI tool, or cloud service, even for well-known ones
  like React, Next.js, Prisma, Express, Tailwind, Django, or Spring Boot. Your
  training data may not reflect recent API changes or version updates.

  Always use for API syntax questions, configuration options, version migration
  issues, "how do I" questions mentioning a library name, debugging that involves
  library-specific behavior, setup instructions, and CLI tool usage.

  Use even when you think you know the answer. Do not rely on training data for
  API details, signatures, or configuration options because they are frequently
  outdated. Always verify against current docs. Prefer this over web search for
  library documentation and API details.
license: MIT
compatibility: Requires Node.js 22.13 or newer and network access.
---

# Documentation Lookup

Retrieve current documentation and code examples for any library using the Context7 CLI.

Run commands with the pinned CLI version so lookups remain reproducible:

```bash
npx ctx7@0.8.2 library <name> "<query>"
npx ctx7@0.8.2 docs <libraryId> "<query>"
```

## Workflow

Resolve the library name to an ID, then query docs with that ID.

```bash
# Step 1: Resolve library ID
npx ctx7@0.8.2 library <name> "<query>"

# Step 2: Query documentation
npx ctx7@0.8.2 docs <libraryId> "<query>"
```

Call `library` first to obtain a valid library ID unless the user explicitly provides a library ID in the format `/org/project` or `/org/project/version`.

Do not run these commands more than three times per question. If you cannot find what you need after three attempts, use the best result you have.

## Resolve a Library

Use the official library name and pass a query that describes the user's intent:

```bash
npx ctx7@0.8.2 library React "How to clean up useEffect with async operations"
npx ctx7@0.8.2 library "Next.js" "How to set up app router with a proxy"
npx ctx7@0.8.2 library Prisma "How to define one-to-many relations with cascade delete"
```

Do not include sensitive or confidential information such as API keys, passwords, credentials, personal data, or proprietary code in the query.

Select the most relevant result using:

1. Exact or closest name match
2. Description relevance to the query
3. Documentation coverage
4. Source reputation
5. Benchmark score

If multiple good matches exist, acknowledge this and proceed with the most relevant one. If no good match exists, state that clearly and suggest query refinements. Ask for clarification when the name is ambiguous.

If the user specifies a version, use a matching version-specific library ID from the result:

```bash
npx ctx7@0.8.2 docs /vercel/next.js/v16.2.9 "How to set up app router"
```

## Query Documentation

Use the resolved library ID with a focused question:

```bash
npx ctx7@0.8.2 docs /react/react "How to clean up useEffect with async operations"
npx ctx7@0.8.2 docs /vercel/next.js "How to add an authentication proxy to app router"
npx ctx7@0.8.2 docs /prisma/orm "How to define one-to-many relations with cascade delete"
```

If you know the programming language the user writes in, add `--language` so code examples in that language rank first:

```bash
npx ctx7@0.8.2 docs /websites/twilio "How to send an SMS" --language Ruby
```

Keep each query to one topic. If the question spans multiple distinct concepts, run a separate `docs` command for each concept unless the question is specifically about how they interact.

Describe the documentation to retrieve rather than the task to complete. Avoid vague one-word queries and broad multi-topic queries.

## Authentication

Documentation lookup works without authentication. For higher rate limits, use the `CONTEXT7_API_KEY` environment variable or run:

```bash
npx ctx7@0.8.2 login
```

## Error Handling

If a command fails because the monthly quota is exhausted:

1. Tell the user that the Context7 quota is exhausted.
2. Suggest authenticating with `npx ctx7@0.8.2 login` for higher limits.
3. If authentication is unavailable, use web search and clearly state that Context7 was unavailable.

Do not silently fall back to training data.

## Common Mistakes

- Library IDs require a `/` prefix, such as `/react/react`.
- Run `library` before `docs` unless the user provides a valid library ID.
- Use descriptive queries instead of single words.
- Split unrelated topics into separate documentation queries.
- Never include secrets or proprietary code in a query.
