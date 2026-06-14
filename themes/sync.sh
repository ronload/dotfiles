#!/usr/bin/env bash
# Re-vendor tokyonight-moon theme files from the locally-installed
# tokyonight.nvim plugin into themes/tokyonight-moon/.
#
# These vendored copies are the single source of truth for every app's
# colorscheme (ghostty, tmux, delta, yazi, eza, bat), so terminal/app
# themes stay decoupled from Neovim's plugin directory. Run this after
# updating tokyonight.nvim to pull in upstream palette changes, then
# review the diff before committing.
#
# NOT touched here: tokyonight-moon/fzf/tokyonight_moon.conf is hand-maintained
# (our custom Telescope-style palette deliberately diverges from the upstream fzf
# extra), so it is intentionally absent from the maps below and never overwritten.
set -euo pipefail

SRC="${HOME}/.local/share/nvim/lazy/tokyonight.nvim/extras"
DEST="$(cd "$(dirname "$0")" && pwd)/tokyonight-moon"

if [[ ! -d "${SRC}" ]]; then
  echo "tokyonight.nvim not found at ${SRC}" >&2
  echo "Open nvim once (or run :Lazy sync) to install it first." >&2
  exit 1
fi

# <src path under extras/> : <dest path under tokyonight-moon/>
# bat has no dedicated extra; it consumes the sublime tmTheme (used by both
# standalone `bat` and delta's syntax highlighting).
maps=(
  "ghostty/tokyonight_moon:ghostty/tokyonight_moon"
  "tmux/tokyonight_moon.tmux:tmux/tokyonight_moon.tmux"
  "delta/tokyonight_moon.gitconfig:delta/tokyonight_moon.gitconfig"
  "yazi/tokyonight_moon.toml:yazi/tokyonight_moon.toml"
  "eza/tokyonight_moon.yml:eza/tokyonight_moon.yml"
  "sublime/tokyonight_moon.tmTheme:bat/tokyonight_moon.tmTheme"
)

for m in "${maps[@]}"; do
  s="${SRC}/${m%%:*}"
  d="${DEST}/${m##*:}"
  mkdir -p "$(dirname "${d}")"
  cp "${s}" "${d}"
  echo "vendored ${m##*:}"
done

# Compatibility fixup: tokyonight's yazi extra still ships the legacy `name = `
# matcher in [filetype] rules, but yazi >= 26.x renamed it to `url = ` and now
# rejects the old key ("at least one of `url` or `mime` must be specified").
# Rewrite it so re-vendoring stays loadable; becomes a no-op once upstream updates.
sed -i '' 's/{ name = /{ url = /g' "${DEST}/yazi/tokyonight_moon.toml"
echo "patched yazi/tokyonight_moon.toml (name -> url for yazi >= 26.x)"

echo "Done. Review with: git -C \"${DEST}\" status ."
