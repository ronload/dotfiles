#!/bin/bash
set -f

# ── Colors (tokyonight-moon palette) ───────────────────
readonly BLUE='\033[38;2;122;162;247m'
readonly ORANGE='\033[38;2;255;158;100m'
readonly GREEN='\033[38;2;158;206;106m'
readonly CYAN='\033[38;2;125;207;255m'
readonly RED='\033[38;2;247;118;142m'
readonly YELLOW='\033[38;2;224;175;104m'
readonly WHITE='\033[38;2;192;202;245m'
readonly MAGENTA='\033[38;2;187;154;247m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'
readonly SEP=" ${DIM}│${RESET} "

# ── Helpers ────────────────────────────────────────────
format_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    awk "BEGIN {printf \"%.1fm\", $n / 1000000}"
  elif [ "$n" -ge 1000 ]; then
    awk "BEGIN {printf \"%.0fk\", $n / 1000}"
  else
    printf "%d" "$n"
  fi
}

color_for_pct() {
  local pct=$1
  if [ "$pct" -ge 90 ]; then printf "%b" "$RED"
  elif [ "$pct" -ge 70 ]; then printf "%b" "$YELLOW"
  elif [ "$pct" -ge 50 ]; then printf "%b" "$ORANGE"
  else printf "%b" "$GREEN"
  fi
}

build_bar() {
  local pct=$1 width=$2
  [ "$pct" -lt 0 ] 2>/dev/null && pct=0
  [ "$pct" -gt 100 ] 2>/dev/null && pct=100
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar_color
  bar_color=$(color_for_pct "$pct")
  printf "%b%s%b%s%b" "$bar_color" "$(printf '▦%.0s' $(seq 1 "$filled") 2>/dev/null)" "$DIM" "$(printf '⬚%.0s' $(seq 1 "$empty") 2>/dev/null)" "$RESET"
}

iso_to_epoch() {
  local input="$1"
  # Strip fractional seconds while preserving timezone
  input=$(echo "$input" | sed 's/\.[0-9]*//')
  # Normalize Z to +0000
  input="${input/Z/+0000}"
  # Remove colon from timezone offset (+00:00 -> +0000)
  input=$(echo "$input" | sed 's/\([+-][0-9][0-9]\):\([0-9][0-9]\)$/\1\2/')
  # Try with timezone first, fall back to without
  date -j -f "%Y-%m-%dT%H:%M:%S%z" "$input" +%s 2>/dev/null ||
    date -j -f "%Y-%m-%dT%H:%M:%S" "$input" +%s 2>/dev/null
}

format_time() {
  local epoch=$1 fmt=$2
  date -j -r "$epoch" +"$fmt" 2>/dev/null | sed 's/^ //; s/\.//g' | tr '[:upper:]' '[:lower:]'
}

format_duration() {
  local elapsed=$1
  if [ "$elapsed" -ge 3600 ]; then
    printf "%dh%dm" $(( elapsed / 3600 )) $(( (elapsed % 3600) / 60 ))
  elif [ "$elapsed" -ge 60 ]; then
    printf "%dm" $(( elapsed / 60 ))
  else
    printf "%ds" "$elapsed"
  fi
}

get_oauth_token() {
  [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ] && echo "$CLAUDE_CODE_OAUTH_TOKEN" && return

  if command -v security >/dev/null 2>&1; then
    local blob token
    blob=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
    token=$(echo "$blob" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    [ -n "$token" ] && [ "$token" != "null" ] && echo "$token" && return
  fi

  local creds_file="$HOME/.claude/.credentials.json"
  if [ -f "$creds_file" ]; then
    local token
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds_file" 2>/dev/null)
    [ -n "$token" ] && [ "$token" != "null" ] && echo "$token" && return
  fi
}

fetch_usage_data() {
  local cache_file="/tmp/claude/statusline-usage-cache.json"
  mkdir -p /tmp/claude

  if [ -f "$cache_file" ]; then
    local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file") ))
    if [ "$cache_age" -lt 60 ]; then
      cat "$cache_file"
      return
    fi
  fi

  local token
  token=$(get_oauth_token)
  if [ -n "$token" ]; then
    local response
    response=$(curl -s --max-time 5 \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $token" \
      -H "anthropic-beta: oauth-2025-04-20" \
      -H "User-Agent: claude-code" \
      "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)
    if echo "$response" | jq -e '.five_hour' >/dev/null 2>&1; then
      echo "$response" > "$cache_file"
      echo "$response"
      return
    fi
  fi

  # Fall back to stale cache
  [ -f "$cache_file" ] && cat "$cache_file"
}

build_line1() {
  local model_name=$1 pct_used=$2 dirname=$3 git_branch=$4 git_dirty=$5 session_duration=$6

  local pct_color
  pct_color=$(color_for_pct "$pct_used")

  local line="${CYAN}֍ ${model_name}${RESET}"
  line+="${SEP}${pct_color}󱅴 ${pct_used}%${RESET}"
  line+="${SEP}${BLUE} ${dirname}${RESET}"
  [ -n "$git_branch" ] && line+="${SEP}${MAGENTA}${git_branch}${RED}${git_dirty}${RESET}"
  [ -n "$session_duration" ] && line+="${SEP}${DIM}⏱ ${RESET}${WHITE}${session_duration}${RESET}"

  printf "%b" "$line"
}

build_rate_line() {
  local usage_data=$1 key=$2 label=$3 bar_w=10
  local pct reset_epoch bar color

  pct=$(echo "$usage_data" | jq -r ".$key.utilization // 0" | awk '{printf "%.0f", $1}')
  reset_epoch=$(iso_to_epoch "$(echo "$usage_data" | jq -r ".$key.resets_at // empty")")
  bar=$(build_bar "$pct" "$bar_w")
  color=$(color_for_pct "$pct")

  printf "%b" "${DIM}${label}${RESET} ${bar} ${color}$(printf '%3d' "$pct")%${RESET} ${DIM}⟳${RESET} ${DIM}$(format_time "$reset_epoch" "%b %d, %l:%M%p")${RESET}"
}

build_rate_lines() {
  local usage_data=$1

  echo "$usage_data" | jq -e . >/dev/null 2>&1 || return

  build_rate_line "$usage_data" "five_hour" "current"
  printf "\n"
  build_rate_line "$usage_data" "seven_day" "weekly "
}

# ── Main ───────────────────────────────────────────────
main() {
  local input
  input=$(cat)

  if [ -z "$input" ]; then
    printf "Claude"
    return 0
  fi

  # Extract JSON data (single jq call)
  local model_name size input_tokens cache_create cache_read cwd session_start
  eval "$(echo "$input" | jq -r '
    @sh "model_name=\(.model.display_name // "Claude")",
    @sh "size=\(.context_window.context_window_size // 200000)",
    @sh "input_tokens=\(.context_window.current_usage.input_tokens // 0)",
    @sh "cache_create=\(.context_window.current_usage.cache_creation_input_tokens // 0)",
    @sh "cache_read=\(.context_window.current_usage.cache_read_input_tokens // 0)",
    @sh "cwd=\(.cwd // "")",
    @sh "session_start=\(.session.start_time // "")"
  ')"

  [ "$size" -eq 0 ] 2>/dev/null && size=200000
  local current=$(( input_tokens + cache_create + cache_read ))
  local pct_used=$(( size > 0 ? current * 100 / size : 0 ))

  # Working directory and git info
  [ -z "$cwd" ] || [ "$cwd" = "null" ] && cwd=$(pwd)
  local dirname
  dirname=$(basename "$cwd")

  local git_branch="" git_dirty=""
  if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
    [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && git_dirty="*"
  fi

  # Session duration
  local session_duration=""
  if [ -n "$session_start" ] && [ "$session_start" != "null" ]; then
    local start_epoch
    start_epoch=$(iso_to_epoch "$session_start")
    if [ -n "$start_epoch" ]; then
      session_duration=$(format_duration $(( $(date +%s) - start_epoch )))
    fi
  fi

  # Output
  build_line1 "$model_name" "$pct_used" "$dirname" "$git_branch" "$git_dirty" "$session_duration"

  local usage_data
  usage_data=$(fetch_usage_data)
  if [ -n "$usage_data" ]; then
    printf "\n\n"
    build_rate_lines "$usage_data"
  fi
}

main "$@"
