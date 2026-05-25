# List available recipes
default:
  @just --list

# Run all linters and formatters
ci: lint-lua lint-shell lint-zsh format-lua format-shell

# Run all linters
lint: lint-lua lint-shell lint-zsh

# Run all formatters in check mode
format: format-lua format-shell

# Lint Lua files with luacheck
lint-lua:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(git ls-files '*.lua')
  [ -z "$files" ] && exit 0
  luacheck $files

# Lint shell scripts with shellcheck
lint-shell:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(git ls-files '*.sh')
  [ -z "$files" ] && exit 0
  shellcheck $files

# Check zsh syntax
lint-zsh:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(git ls-files 'zsh/**/*')
  [ -z "$files" ] && exit 0
  zsh -n $files

# Check Lua formatting with stylua
format-lua:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(git ls-files '*.lua')
  [ -z "$files" ] && exit 0
  stylua --check $files

# Check shell formatting with shfmt
format-shell:
  #!/usr/bin/env bash
  set -euo pipefail
  files=$(git ls-files '*.sh')
  [ -z "$files" ] && exit 0
  shfmt -i 2 -ci -d $files
