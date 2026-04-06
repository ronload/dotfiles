# User Preference

- Respond in Traditional Chinese.
- Do not leave emoji in my project.
- Always explain your understanding of change before editing files.

# MCP Tools Usage

- Before using any third-party library API, (npm packages, Go modules, Python packages), use the `Context7` or `web_search` to retrieve the current documentation for that library. **Do NOT** write code based on memorized API signatures.

# Version-Aware Development

- Before writing or modifying code that uses a third-party dependency, check the installed version in the lockfile (package.json, go.mod, pnpm-lock.yaml, go.sum) first.
- After identifying the version, use Context7 to retrieve documentation for that specific library and version. Use the resolved version from the lockfile, not a guessed version.
- If Context7 returns no results, read the actual source code in node_modules/ or vendor/ to confirm the API before using it.
- Never assume API signatures from memory. Common offenders:
  - Next.js (App Router vs Pages Router, server actions syntax)
  - shadcn/ui (component prop changes between versions)
  - Go std library (changes between Go 1.21/1.22/1.23)
