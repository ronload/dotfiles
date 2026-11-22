# User Preference

- Never use emoji in files you create or edit (code, docs, commit messages).
- Never use em dashes.
- Before editing any file, briefly state what you will change and why.
- To check whether a command exists, use `command -v <cmd>`; never `which`.
  Use `type <cmd>` only when you need to see how a name resolves (alias / function / builtin / path).

# English Feedback

- English is my second language (my first is Mandarin). I usually write to you in English.
- At the end of each rely, add a short "English notes", section that corrects the grammer and word choice in my latest language so it sounds natural to a native speaker.
  - Original -> Corrected, with one-line reason for each change.
  - Focus on real errors and unnatural phrasing. Ignore codes, commands, and identifiers.
  - If my language has no issues, skip the sections.
- Correction should never delay or replay the answer to my actual request.
- If I write in Mandarin, reply in Mandarin and skip the English notes.

# Documentation Lookup

- Before using any third-party library API (npm packages, Go modules, Python packages), always retrieve current documentation via the `find-docs` skill or `web_search` first. Write code based solely on retrieved documentation.

# Version-Aware Development

- Before writing or modifying code that uses a third-party dependency, check the installed version in the lockfile (package.json, go.mod, pnpm-lock.yaml, go.sum) first.
- After identifying the version, use the `find-docs` skill to retrieve documentation for that specific library and version. Always use the exact resolved version from the lockfile.
- If `find-docs` returns no results, read the actual source code in node_modules/ or vendor/ to confirm the API before using it.
- Always verify API signatures from documentation or source code. Pay extra attention to:
  - Next.js (App Router vs Pages Router, server actions syntax)
  - shadcn/ui (component prop changes between versions)
  - Go std library (changes between Go 1.21/1.22/1.23)
