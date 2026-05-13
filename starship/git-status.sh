#!/usr/bin/env bash
# Compact git status formatter for the starship custom.git_status module.
# Emits a single space-separated line of 3-char labels (e.g. "mod stg unt a2"),
# or nothing when the repo is clean / not a repo. Starship wraps the output in
# brackets and styles it.

set -u

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

status=$(git status --porcelain=v2 --branch 2>/dev/null) || exit 0

ahead=0
behind=0
has_conflict=0
has_staged=0
has_modified=0
has_deleted=0
has_renamed=0
has_untracked=0

while IFS= read -r line; do
  case "$line" in
    '# branch.ab '*)
      read -r _ _ a b <<<"$line"
      ahead=${a#+}
      behind=${b#-}
      ;;
    '#'*) ;;
    '? '*) has_untracked=1 ;;
    'u '*) has_conflict=1 ;;
    '1 '*|'2 '*)
      xy=${line:2:2}
      x=${xy:0:1}
      y=${xy:1:1}
      [ "$x" != "." ] && has_staged=1
      [ "$y" = "M" ] && has_modified=1
      [ "$y" = "D" ] && has_deleted=1
      [ "$x" = "R" ] && has_renamed=1
      ;;
  esac
done <<<"$status"

stash_count=$(git rev-list --walk-reflogs --count refs/stash 2>/dev/null || echo 0)

parts=()
(( has_conflict ))    && parts+=("cnf")
(( has_modified ))    && parts+=("mod")
(( has_staged ))      && parts+=("stg")
(( has_renamed ))     && parts+=("ren")
(( has_deleted ))     && parts+=("del")
(( has_untracked ))   && parts+=("new")
(( stash_count > 0 )) && parts+=("sth")

if   (( ahead > 0 && behind > 0 )); then parts+=("a${ahead}b${behind}")
elif (( ahead > 0 ));               then parts+=("a${ahead}")
elif (( behind > 0 ));              then parts+=("b${behind}")
fi

(( ${#parts[@]} == 0 )) && exit 0

echo "${parts[*]}"
