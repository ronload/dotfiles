# Hand-written zsh prompt. Mirrors what the previous starship.toml produced:
#   <dir> on <branch> (<STATE n/m>) is [mod stg new ⇡2]
#   󰘧
# Top line is rebuilt every precmd; the character line uses zsh's %(?.t.f).

setopt PROMPT_SUBST

# Escape % so dynamic strings (branch names) can't be reinterpreted as prompt escapes.
_prompt_q() { print -rn -- "${1//\%/%%}"; }

_prompt_git() {
  local git_dir
  git_dir=$(command git rev-parse --git-dir 2>/dev/null) || return 0

  local branch
  branch=$(command git symbolic-ref --short HEAD 2>/dev/null) ||
    branch=$(command git rev-parse --short HEAD 2>/dev/null) ||
    return 0

  print -rn -- " on %B%F{blue}$(_prompt_q "$branch")%f%b"

  local state="" progress=""
  if [[ -d "$git_dir/rebase-merge" ]]; then
    state="REBASING"
    if [[ -r "$git_dir/rebase-merge/msgnum" && -r "$git_dir/rebase-merge/end" ]]; then
      progress=" $(<"$git_dir/rebase-merge/msgnum")/$(<"$git_dir/rebase-merge/end")"
    fi
  elif [[ -d "$git_dir/rebase-apply" ]]; then
    state="REBASING"
    if [[ -r "$git_dir/rebase-apply/next" && -r "$git_dir/rebase-apply/last" ]]; then
      progress=" $(<"$git_dir/rebase-apply/next")/$(<"$git_dir/rebase-apply/last")"
    fi
  elif [[ -f "$git_dir/MERGE_HEAD" ]]; then
    state="MERGING"
  elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
    state="CHERRY-PICKING"
  elif [[ -f "$git_dir/REVERT_HEAD" ]]; then
    state="REVERTING"
  elif [[ -f "$git_dir/BISECT_LOG" ]]; then
    state="BISECTING"
  fi
  if [[ -n "$state" ]]; then
    print -rn -- " (%B%F{red}${state}${progress}%f%b)"
  fi

  local status_out
  status_out=$(command git status --porcelain=v2 --branch 2>/dev/null) || return 0

  local ahead=0 behind=0
  local has_conflict=0 has_staged=0 has_modified=0 has_deleted=0 has_renamed=0 has_untracked=0
  local line rest a b xy x y
  while IFS= read -r line; do
    case "$line" in
      '# branch.ab '*)
        rest=${line#'# branch.ab '}
        a=${rest%% *}
        b=${rest#* }
        ahead=${a#+}
        behind=${b#-}
        ;;
      '#'*) ;;
      '? '*) has_untracked=1 ;;
      'u '*) has_conflict=1 ;;
      '1 '* | '2 '*)
        xy=${line:2:2}
        x=${xy:0:1}
        y=${xy:1:1}
        [[ "$x" != "." ]] && has_staged=1
        [[ "$y" == "M" ]] && has_modified=1
        [[ "$y" == "D" ]] && has_deleted=1
        [[ "$x" == "R" ]] && has_renamed=1
        ;;
    esac
  done <<<"$status_out"

  local stash_count
  stash_count=$(command git rev-list --walk-reflogs --count refs/stash 2>/dev/null) || stash_count=0

  local -a parts
  ((has_conflict)) && parts+=("cnf")
  ((has_modified)) && parts+=("mod")
  ((has_staged)) && parts+=("stg")
  ((has_renamed)) && parts+=("ren")
  ((has_deleted)) && parts+=("del")
  ((has_untracked)) && parts+=("new")
  ((stash_count > 0)) && parts+=("sth")
  if ((ahead > 0 && behind > 0)); then
    parts+=("⇡${ahead}⇣${behind}")
  elif ((ahead > 0)); then
    parts+=("⇡${ahead}")
  elif ((behind > 0)); then
    parts+=("⇣${behind}")
  fi

  if ((${#parts[@]} > 0)); then
    local dim=$'%{\e[2m%}' rst=$'%{\e[22m%}'
    print -rn -- " is ${dim}[${(j: :)parts}]${rst}"
  fi
}

typeset -g _PROMPT_CMD_RAN=0
typeset -g PROMPT_CHAR_COLOR='%F{green}'

_prompt_preexec() {
  _PROMPT_CMD_RAN=1
}

_prompt_precmd() {
  local last_status=$?
  if ((_PROMPT_CMD_RAN)); then
    _PROMPT_CMD_RAN=0
    if ((last_status == 0)); then
      PROMPT_CHAR_COLOR='%F{blue}'
    else
      PROMPT_CHAR_COLOR='%F{red}'
    fi
  else
    PROMPT_CHAR_COLOR='%F{green}'
  fi
  PROMPT_TOP="%B%F{magenta} %1~%f%b$(_prompt_git)"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd
add-zsh-hook preexec _prompt_preexec

PROMPT='${PROMPT_TOP}
${PROMPT_CHAR_COLOR}%B󰘧%b%f '
RPROMPT=''
