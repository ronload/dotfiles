Review both staged (`git diff --cached`) and unstaged (`git diff` and `git status`) changes to understand the full picture, then propose how to organize them into atomic commits.
If nothing is staged yet, suggest which files to stage together based on logical grouping, and explain your reasoning.
Write a concise commit message following Conventional Commits format.
The message should be in English, lowercase, and without a period at the end.
Follow the atomic commit principle: each commit should contain exactly one logical change.
Never mention Claude, AI, or any AI assistant in the commit message.
After writing the commit message, ALWAYS ask for my confirmation before executing `git commit`.
NEVER commit directly, even in auto-accept mode.
