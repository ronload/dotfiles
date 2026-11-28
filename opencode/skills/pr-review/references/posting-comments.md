# Posting a review to GitHub

Use this only for a PR, and only after the user asks to post the review. Post bug and rule issues only. Code quality issues stay in the terminal report: leave them out of the comments and out of the review summary.

1. Draft every comment first and show the drafts to the user. Post only after the user confirms, even when the environment approves tool calls without prompting.
2. Run `gh pr view <PR> --json headRefOid`. If it no longer equals `HEAD_SHA`, tell the user the PR changed after the review and ask whether to post anyway.
3. Post one review that carries every inline comment. Write the request body to a JSON file in the temporary directory, then run `gh api repos/{owner}/{repo}/pulls/<number>/reviews --method POST --input <file>`. `gh` fills in `{owner}` and `{repo}` from the current repository.

   ```json
   {
     "commit_id": "<full HEAD_SHA>",
     "event": "COMMENT",
     "body": "<short summary of the review>",
     "comments": [
       {
         "path": "src/auth.ts",
         "start_line": 67,
         "start_side": "RIGHT",
         "line": 72,
         "side": "RIGHT",
         "body": "<comment>"
       }
     ]
   }
   ```

   `line` is the last line of the range and `start_line` the first, both as line numbers in the `HEAD_SHA` version of the file. Omit `start_line` and `start_side` for a single-line comment. Every commented line must fall inside a diff hunk, or GitHub rejects the whole review.

4. When no bug or rule issue was confirmed, post a single comment instead with `gh pr comment <PR> --body-file <file>`:

   ```markdown
   ## Code review

   No issues found. Checked for bugs and AGENTS.md compliance.
   ```

Comment rules:

- One comment per unique issue. Never post duplicates.
- Start each comment with the priority tag and title, such as `[P1] Release the lock on the error path`. Follow with one paragraph that states the scenario, inputs, or environment the issue needs, and why it is a problem. For a rule violation, link the rule file with a full-SHA permalink.
- Keep the tone matter-of-fact. Do not flatter ("Great job", "Thanks for"), and do not claim the issue is more severe than it is.
- Outside suggestion blocks, keep code in a comment to three lines or fewer.
- For a small, self-contained fix, include a committable suggestion block. For larger fixes (six or more lines, structural changes, or changes spanning several locations), describe the fix without a suggestion block. Never post a suggestion unless committing it fixes the issue entirely. Put only replacement code in a suggestion block, and preserve the exact leading whitespace of the replaced lines.
- Write in the language of the PR description. Do not use emoji.
- Always use `"event": "COMMENT"`. Never approve or request changes.
