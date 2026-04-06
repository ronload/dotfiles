#!/bin/bash
# PostToolUse hook: auto-format files after Edit/Write.
# Reads the tool output JSON from stdin, extracts file_path,
# detects the formatter by extension, and runs it if available.
# If no formatter is found or the command is missing, exits silently.

set -f

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

[ -z "$FILE_PATH" ] && exit 0
[ -f "$FILE_PATH" ] || exit 0

EXT="${FILE_PATH##*.}"

case "$EXT" in
  js|jsx|ts|tsx|css|scss|json|md|html|yaml|yml|vue|svelte|graphql)
    command -v prettier &>/dev/null && prettier --write "$FILE_PATH" &>/dev/null
    ;;
  go)
    command -v gofmt &>/dev/null && gofmt -w "$FILE_PATH" &>/dev/null
    ;;
  rs)
    command -v rustfmt &>/dev/null && rustfmt "$FILE_PATH" &>/dev/null
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" &>/dev/null
    elif command -v black &>/dev/null; then
      black -q "$FILE_PATH" &>/dev/null
    fi
    ;;
  swift)
    command -v swiftformat &>/dev/null && swiftformat "$FILE_PATH" &>/dev/null
    ;;
  lua)
    command -v stylua &>/dev/null && stylua "$FILE_PATH" &>/dev/null
    ;;
  sh|bash|zsh)
    command -v shfmt &>/dev/null && shfmt -w "$FILE_PATH" &>/dev/null
    ;;
esac

exit 0
