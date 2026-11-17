#!/bin/bash
#
# worktree-start.sh -- OpenCode worktree start command
#
# OpenCode runs a project's start command inside every worktree it creates,
# with OPENCODE_WORKTREE_BASE set to the checkout the worktree came from and
# OPENCODE_WORKTREE_PATH set to the new worktree. git-worktreeinclude reads
# .worktreeinclude from the source checkout, so a project without one has
# nothing to copy and is skipped before the tool is needed.

set -euo pipefail

source_dir="${OPENCODE_WORKTREE_BASE:?must run as an OpenCode worktree start command}"
target_dir="${OPENCODE_WORKTREE_PATH:?must run as an OpenCode worktree start command}"

if [[ ! -f "${source_dir}/.worktreeinclude" ]]; then
  exit 0
fi

if ! command -v git-worktreeinclude >/dev/null; then
  echo "git-worktreeinclude not found; install it with: brew bundle --file ~/dotfiles/Brewfile" >&2
  exit 1
fi

cd "${target_dir}"
git-worktreeinclude apply --from "${source_dir}"
