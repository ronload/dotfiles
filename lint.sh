#!/bin/bash
# Run shellcheck on all tracked bash scripts.
# zsh files (zshrc, *.zsh, etc.) are excluded — shellcheck does not support zsh.
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

if ! command -v shellcheck &>/dev/null; then
  echo "shellcheck not installed. Install via: brew install shellcheck" >&2
  exit 1
fi

files=()
while IFS= read -r f; do
  files+=("$f")
done < <(git ls-files '*.sh')

if [ ${#files[@]} -eq 0 ]; then
  echo "No shell scripts to check"
  exit 0
fi

echo "Running shellcheck on ${#files[@]} file(s)..."
shellcheck "${files[@]}"
echo "shellcheck passed"
