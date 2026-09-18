---
name: create-readme
description: Write or rewrite a project's README.md from the repository's actual structure and conventions. Use when the user asks to create, generate, rewrite or improve a README, or asks for a project overview to live in README.md. Do not use for other documentation files, for editing a single section the user quotes, or for answering questions about a project in chat.
license: MIT
allowed-tools: Read Glob Grep
---

The result must be appealing, informative, and easy to read.

## Task

1. Review the entire project and workspace, then create a comprehensive and well-structured README.md file for the project.
2. Follow `references/readme-structure.md` for section order, tone, and length.
3. Do not use emojis, and keep the readme concise and to the point.
4. Do not include sections like "LICENSE", "CONTRIBUTING", "CHANGELOG", etc. There are dedicated files for those sections.
5. Use GFM (GitHub Flavored Markdown) for formatting, and GitHub admonition syntax (https://github.com/orgs/community/discussions/16925) where appropriate.
6. If you find a logo or icon for the project, use it in the readme's header.
7. Render callout-style blockquotes as GitHub alerts: open with `[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, or `[!CAUTION]` on the first line, every line prefixed with `>`, and pick the type by intent. Reserve a plain blockquote only for a verbatim quotation; never label a quote as an alert. Only these five markers are valid on GitHub; others fall back to plain blockquotes.
