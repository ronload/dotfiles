#!/bin/bash
#
# sync-worktree-start.sh -- point OpenCode git projects at worktree-start.sh
#
# OpenCode keeps each project's worktree start command in its own database
# rather than in opencode.jsonc, so it cannot be symlinked like the rest of the
# config. This sets it through the OpenCode API for every git project OpenCode
# already knows about; a project opened for the first time afterwards needs
# another run. A project that has a different start command keeps it.

set -euo pipefail

start_command="$(printf '%q' "${HOME}/dotfiles/opencode/worktree-start.sh")"
update_body="$(printf '%s' "${start_command}" | jaq -R -c '{commands: {start: .}}')"

projects="$(opencode api project.list)"
git_projects="$(
  jaq -r '.[] | select(.vcs == "git") | [.id, .canonical, (.commands.start // "")] | @tsv' <<<"${projects}"
)"

while IFS=$'\t' read -r project_id canonical current_command; do
  [[ -n "${project_id}" ]] || continue
  label="${canonical/#${HOME}/~}"
  if [[ "${current_command}" = "${start_command}" ]]; then
    echo "✓ ${label} already uses worktree-start.sh"
  elif [[ -n "${current_command}" ]]; then
    echo "- ${label} keeps its own start command"
  else
    # opencode would otherwise read the rest of the project list from stdin.
    opencode api project.update --param "projectID=${project_id}" --data "${update_body}" >/dev/null </dev/null
    echo "✓ ${label} now uses worktree-start.sh"
  fi
done <<<"${git_projects}"
