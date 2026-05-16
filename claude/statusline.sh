#!/bin/bash
set -f

# ── Colors (ANSI named slots; terminal palette controls actual RGB) ───
readonly BLUE='\033[34m'
readonly GREEN='\033[32m'
readonly CYAN='\033[36m'
readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly WHITE='\033[39m'
readonly MAGENTA='\033[35m'
readonly DIM='\033[2m'
readonly RESET='\033[0m'
readonly SEP=" ${DIM}│${RESET} "

# ── Usage fetch config ─────────────────────────────────
readonly CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude"
readonly CACHE_TTL=60          # seconds a cached response stays fresh
readonly DEFAULT_BACKOFF=300   # backoff when the API fails without Retry-After
readonly MAX_BACKOFF=3600      # cap on any backoff window
SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)"
readonly SCRIPT_PATH="$SCRIPT_DIR/$(basename "$0")"

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
  else printf "%b" "$GREEN"
  fi
}

build_bar() {
  local pct=$1 width=$2
  [ "$pct" -lt 0 ] 2>/dev/null && pct=0
  [ "$pct" -gt 100 ] 2>/dev/null && pct=100
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar_color filled_str="" empty_str=""
  bar_color=$(color_for_pct "$pct")
  [ "$filled" -gt 0 ] && filled_str=$(printf '■%.0s' $(seq 1 "$filled"))
  [ "$empty" -gt 0 ] && empty_str=$(printf '□%.0s' $(seq 1 "$empty"))
  printf "%b%s%b%s%b" "$bar_color" "$filled_str" "$DIM" "$empty_str" "$RESET"
}

iso_to_epoch() {
  local input="$1"
  # shellcheck disable=SC2001  # capture-group regex; bash parameter expansion is less readable
  # Strip fractional seconds while preserving timezone
  input=$(echo "$input" | sed 's/\.[0-9]*//')
  # Normalize Z to +0000
  input="${input/Z/+0000}"
  # shellcheck disable=SC2001  # capture-group regex; bash parameter expansion is less readable
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

# Render path: only ever reads the cache, never blocks on the network.
fetch_usage_data() {
  local cache_file="$CACHE_DIR/statusline-usage-cache.json"

  # Decide whether the cache is stale and a refresh is warranted
  local stale=1
  if [ -f "$cache_file" ]; then
    local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
    [ "$cache_age" -lt "$CACHE_TTL" ] && stale=0
  fi

  # Kick off a detached background refresh; the render path stays instant
  [ "$stale" -eq 1 ] && refresh_usage_async

  # Emit whatever is cached (possibly slightly stale — acceptable)
  [ -f "$cache_file" ] && cat "$cache_file"
}

# Spawn a detached refresher, unless one is running or we are backing off.
refresh_usage_async() {
  local backoff_file="$CACHE_DIR/statusline-usage-backoff"
  local lock_dir="$CACHE_DIR/statusline-usage.lock"

  # A refresh is already running (fresh lock) — skip spawning another
  if [ -d "$lock_dir" ]; then
    local lock_age=$(( $(date +%s) - $(stat -f %m "$lock_dir" 2>/dev/null || echo 0) ))
    [ "$lock_age" -lt 60 ] && return
    # a stale lock falls through; refresh_usage clears it
  fi

  # Still inside a backoff window — do not spawn
  if [ -f "$backoff_file" ]; then
    local retry_at
    retry_at=$(cat "$backoff_file" 2>/dev/null)
    [ -n "$retry_at" ] && [ "$(date +%s)" -lt "$retry_at" ] && return
  fi

  # Detached subshell: the child is reparented and outlives this render
  ( bash "$SCRIPT_PATH" --refresh-usage </dev/null >/dev/null 2>&1 & )
}

# Background mode: fetch usage, update the cache, or record a backoff window.
refresh_usage() {
  local cache_file="$CACHE_DIR/statusline-usage-cache.json"
  local backoff_file="$CACHE_DIR/statusline-usage-backoff"
  local lock_dir="$CACHE_DIR/statusline-usage.lock"

  # Honor any active backoff window (negative cache)
  if [ -f "$backoff_file" ]; then
    local retry_at
    retry_at=$(cat "$backoff_file" 2>/dev/null)
    if [ -n "$retry_at" ] && [ "$(date +%s)" -lt "$retry_at" ]; then
      return
    fi
  fi

  # Clear a stale lock left behind by a crashed refresher
  if [ -d "$lock_dir" ]; then
    local lock_age=$(( $(date +%s) - $(stat -f %m "$lock_dir" 2>/dev/null || echo 0) ))
    [ "$lock_age" -gt 60 ] && rmdir "$lock_dir" 2>/dev/null
  fi

  # Atomic lock: mkdir succeeds for exactly one refresher
  mkdir "$lock_dir" 2>/dev/null || return
  # Expand the path now so the trap does not depend on local-var scope at exit
  trap "rmdir '$lock_dir' 2>/dev/null" EXIT

  # Another refresher may have updated the cache just before we locked
  if [ -f "$cache_file" ]; then
    local cache_age=$(( $(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || echo 0) ))
    [ "$cache_age" -lt "$CACHE_TTL" ] && return
  fi

  local token
  token=$(get_oauth_token)
  [ -z "$token" ] && return

  local headers_file body_file http_code
  headers_file=$(mktemp)
  body_file=$(mktemp)
  http_code=$(curl -s --max-time 10 \
    -D "$headers_file" -o "$body_file" -w '%{http_code}' \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "User-Agent: claude-code" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

  if [ "$http_code" = "200" ] && jq -e '.five_hour' "$body_file" >/dev/null 2>&1; then
    # Success: refresh the cache and drop any backoff
    mv "$body_file" "$cache_file" 2>/dev/null
    rm -f "$backoff_file" "$headers_file"
  else
    # Failure: record a backoff window, honoring Retry-After when present
    local retry_after
    retry_after=$(grep -i '^retry-after:' "$headers_file" 2>/dev/null | tr -d '\r' | awk '{print $2}')
    case "$retry_after" in
      ''|*[!0-9]*) retry_after=$DEFAULT_BACKOFF ;;
    esac
    [ "$retry_after" -gt "$MAX_BACKOFF" ] && retry_after=$MAX_BACKOFF
    echo $(( $(date +%s) + retry_after )) > "$backoff_file"
    rm -f "$body_file" "$headers_file"
  fi
}

build_line1() {
  local model_name=$1 pct_used=$2 dirname=$3 git_branch=$4 git_dirty=$5 session_duration=$6

  local pct_color
  pct_color=$(color_for_pct "$pct_used")

  local line="${CYAN}֍ ${model_name}${RESET}"
  line+="${SEP}${pct_color}󱅴 ${pct_used}%${RESET}"
  line+="${SEP}${MAGENTA} ${dirname}${RESET}"
  [ -n "$git_branch" ] && line+="${SEP}${BLUE}${git_branch}${RED}${git_dirty}${RESET}"
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

  printf "%b" "${DIM}${label}${RESET} ${bar} ${color}$(printf '%3d' "$pct")%${RESET} ${DIM}⟳${RESET} ${DIM}$(format_time "$reset_epoch" "%b %d, %H:%M")${RESET}"
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
  mkdir -p "$CACHE_DIR" 2>/dev/null

  # Background refresh mode: fetch usage, update cache/backoff, then exit
  if [ "${1:-}" = "--refresh-usage" ]; then
    refresh_usage
    return 0
  fi

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
