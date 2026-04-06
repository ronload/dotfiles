# User Preference

- Respond in Traditional Chinese.
- Keep all project files free of emoji.
- Always explain your understanding of change before editing files.

# MCP Tools Usage

- Before using any third-party library API (npm packages, Go modules, Python packages), always retrieve current documentation via `Context7` or `web_search` first. Write code based solely on retrieved documentation.

# Version-Aware Development

- Before writing or modifying code that uses a third-party dependency, check the installed version in the lockfile (package.json, go.mod, pnpm-lock.yaml, go.sum) first.
- After identifying the version, use Context7 to retrieve documentation for that specific library and version. Always use the exact resolved version from the lockfile.
- If Context7 returns no results, read the actual source code in node_modules/ or vendor/ to confirm the API before using it.
- Always verify API signatures from documentation or source code. Pay extra attention to:
  - Next.js (App Router vs Pages Router, server actions syntax)
  - shadcn/ui (component prop changes between versions)
  - Go std library (changes between Go 1.21/1.22/1.23)
