#!/usr/bin/env bash
# Custom memory/disk renderer for fastfetch.
# Draws a single-color progress bar whose color tracks usage thresholds.
# Uses ANSI named colors so the terminal palette (e.g. tokyonight-moon set
# in ghostty) controls the actual RGB — change theme, colors follow.
#
# Usage (from fastfetch command module):
#   colored-bar.sh memory
#   colored-bar.sh disk

set -eu

mode="${1:-}"

readonly RED='\033[31m'
readonly YELLOW='\033[33m'
readonly GREEN='\033[32m'
readonly RESET='\033[0m'
# Bold + ANSI blue, matching fastfetch's display.color.keys = "blue"
# rendering. Used to re-emit the key prefix on continuation lines.
readonly KEY_STYLE='\033[1m\033[34m'

color_for_pct() {
  local pct=$1
  if ((pct >= 90)); then
    printf '%b' "${RED}"
  elif ((pct >= 70)); then
    printf '%b' "${YELLOW}"
  else
    printf '%b' "${GREEN}"
  fi
}

build_bar() {
  local pct=$1 width=${2:-10}
  ((pct < 0)) && pct=0
  ((pct > 100)) && pct=100
  local filled=$((pct * width / 100))
  local empty=$((width - filled))
  local color filled_str='' empty_str=''
  color=$(color_for_pct "${pct}")
  ((filled > 0)) && filled_str=$(printf '%.0s■' $(seq 1 "${filled}"))
  ((empty > 0)) && empty_str=$(printf '%.0s□' $(seq 1 "${empty}"))
  printf '%b%s%s%b' "${color}" "${filled_str}" "${empty_str}" "${RESET}"
}

format_bytes() {
  awk -v b="$1" 'BEGIN {
    split("B KiB MiB GiB TiB", u)
    i = 1
    while (b >= 1024 && i < 5) { b /= 1024; i++ }
    if (i == 1) printf "%d %s",   b, u[i]
    else        printf "%.2f %s", b, u[i]
  }'
}

format_line() {
  local used=$1 total=$2
  local pct=0
  ((total > 0)) && pct=$((used * 100 / total))
  local color
  color=$(color_for_pct "${pct}")
  printf '%b %b%d%%%b [%10s / %10s]' \
    "$(build_bar "${pct}")" \
    "${color}" \
    "${pct}" \
    "${RESET}" \
    "$(format_bytes "${used}")" \
    "$(format_bytes "${total}")"
}

case "${mode}" in
  memory)
    read -r used total < <(
      fastfetch -s memory --format json |
        jq -r '.[0].result | "\(.used) \(.total)"'
    )
    format_line "${used}" "${total}"
    ;;
  disk)
    # Mirror fastfetch's native disk filter: drop Hidden system volumes
    # (/System/Volumes/*), keep Regular and External mounts.
    rows=$(
      fastfetch -s disk --format json |
        jq -r '.[0].result[]
                 | select((.volumeType | index("Hidden")) | not)
                 | "\(.bytes.used) \(.bytes.total)"'
    )
    first=1
    while read -r used total; do
      line=$(format_line "${used}" "${total}")
      if ((first)); then
        printf '%s' "${line}"
        first=0
      else
        # Continuation lines lose fastfetch's auto-emitted key prefix;
        # re-emit it manually so multi-volume output stays column-aligned.
        printf '\n%b Disk%b\x1b[20G%s' "${KEY_STYLE}" "${RESET}" "${line}"
      fi
    done <<<"${rows}"
    ;;
  *)
    echo "usage: $(basename "$0") <memory|disk>" >&2
    exit 1
    ;;
esac
