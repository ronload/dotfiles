#!/bin/bash
#
# install_test.sh -- reproducibility test for install.sh
#
# Verifies that install.sh creates every symlink it declares, that the links
# point at the right targets, that none are broken, and that a second run is
# idempotent (re-links nothing). Runs install.sh against a disposable copy of
# the repo and a sandbox $HOME so it never touches the real working tree, the
# real home directory, or the network.
#
# How isolation works:
#   - The repo is copied (tracked files, working-tree content) into a tempdir,
#     so tpm cloning into tmux/plugins/ pollutes the copy, not the real repo.
#   - $HOME points at a fresh tempdir.
#   - Sentinel dirs for fzf-git.sh and tpm are pre-created so install.sh sees
#     them as "already installed" and skips the git clones (no network).
#   - PATH is reduced to /usr/bin:/bin so nvim/bat/tmux (Homebrew, elsewhere)
#     look absent and their post-link steps are skipped deterministically.
#
# Scope note: this checks ONLY the links install.sh declares. Configs that are
# tracked but intentionally not wired up by install.sh (see "Known reproduction
# gaps" in README.md) are out of scope by design.

set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  printf '  ok   %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  FAIL %s\n' "$1"
}

# assert_link <dest> <expected-target>
# Asserts dest is a symlink, resolves to expected-target (ignoring a trailing
# slash), and is not broken.
assert_link() {
  local dest="$1" want="${2%/}" got
  if [[ ! -L "${dest}" ]]; then
    fail "${dest} is not a symlink"
    return
  fi
  got="$(readlink "${dest}")"
  got="${got%/}"
  if [[ "${got}" != "${want}" ]]; then
    fail "${dest} -> ${got} (want ${want})"
    return
  fi
  if [[ ! -e "${dest}" ]]; then
    fail "${dest} is a broken symlink"
    return
  fi
  pass "${dest#"${HOME}"/}"
}

# --- Set up an isolated copy of the repo and a sandbox HOME ---
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

DEST="${WORK}/dotfiles"
mkdir -p "${DEST}"
# Copy tracked files at their current working-tree state (excludes .git,
# ignored, and untracked junk). Reads NUL-delimited names so the copy is
# robust and works with both GNU tar and bsdtar.
(cd "${REPO}" && git ls-files -z | tar --null -T - -cf -) | (cd "${DEST}" && tar -xf -)

SANDBOX_HOME="${WORK}/home"
mkdir -p "${SANDBOX_HOME}"

# Sentinels so install.sh skips the network clones.
mkdir -p "${SANDBOX_HOME}/.local/share/fzf-git.sh"
# ~/.config/tmux is symlinked to ${DEST}/tmux, so this resolved path is where
# install.sh looks for tpm. Pre-creating it skips the tpm clone.
mkdir -p "${DEST}/tmux/plugins/tpm"

echo "Running install.sh (first pass)..."
if ! env HOME="${SANDBOX_HOME}" PATH=/usr/bin:/bin bash "${DEST}/install.sh" >/dev/null 2>&1; then
  echo "install.sh exited non-zero on first run" >&2
  exit 1
fi

# Run the assertions with HOME pointed at the sandbox so the ${dest#"${HOME}"/}
# trimming in assert_link produces readable labels.
HOME="${SANDBOX_HOME}"

echo ""
echo "Checking repo self-link..."
# The sandbox HOME and the repo copy live at different paths, so install.sh must
# create ~/dotfiles -> repo for the absolute-path configs to resolve.
assert_link "${HOME}/dotfiles" "${DEST}"

echo ""
echo "Checking .config symlinks..."
for config in nvim tmux gh ghostty fastfetch karabiner yazi; do
  assert_link "${HOME}/.config/${config}" "${DEST}/${config}"
done

echo ""
echo "Checking home-directory symlinks..."
assert_link "${HOME}/.gitconfig" "${DEST}/git/gitconfig"
assert_link "${HOME}/.gitignore_global" "${DEST}/git/ignore"
assert_link "${HOME}/.config/eza/theme.yml" "${DEST}/themes/tokyonight-moon/eza/tokyonight_moon.yml"

echo ""
echo "Checking shell symlinks..."
assert_link "${HOME}/.zshrc" "${DEST}/zsh/zshrc"
assert_link "${HOME}/.zprofile" "${DEST}/zsh/zprofile"
assert_link "${HOME}/.zshenv" "${DEST}/zsh/zshenv"

echo ""
echo "Checking Claude symlinks..."
for file in CLAUDE.md settings.json statusline.sh; do
  assert_link "${HOME}/.claude/${file}" "${DEST}/claude/${file}"
done

# Skills and hooks are discovered from the repo so the test stays in sync as
# they are added or removed.
for skill_dir in "${DEST}/claude/skills"/*/; do
  skill_name="$(basename "${skill_dir}")"
  assert_link "${HOME}/.claude/skills/${skill_name}" "${skill_dir}"
done
for hook_file in "${DEST}/claude/hooks"/*.sh; do
  hook_name="$(basename "${hook_file}")"
  assert_link "${HOME}/.claude/hooks/${hook_name}" "${hook_file}"
done

# --- Idempotency: a second run must re-link nothing ---
echo ""
echo "Running install.sh (second pass, idempotency)..."
if second="$(env HOME="${SANDBOX_HOME}" PATH=/usr/bin:/bin bash "${DEST}/install.sh" 2>&1)"; then
  if printf '%s\n' "${second}" | grep -qF "Linked "; then
    fail "second run re-created links (not idempotent):"
    printf '%s\n' "${second}" | grep -F "Linked " | sed 's/^/      /'
  else
    pass "second run re-linked nothing"
  fi
else
  fail "second run exited non-zero"
fi

# --- A pre-existing real config dir must be backed up, not clobbered ---
# Karabiner-Elements creates ~/.config/karabiner before install; install.sh must
# move it to .bak and replace it with the symlink (not link inside it).
echo ""
echo "Running install.sh with a pre-existing ~/.config/karabiner..."
HOME2="${WORK}/home2"
mkdir -p "${HOME2}/.config/karabiner"
echo "live-config" >"${HOME2}/.config/karabiner/karabiner.json"
mkdir -p "${HOME2}/.local/share/fzf-git.sh"
mkdir -p "${DEST}/tmux/plugins/tpm"
if env HOME="${HOME2}" PATH=/usr/bin:/bin bash "${DEST}/install.sh" >/dev/null 2>&1; then
  if [[ -L "${HOME2}/.config/karabiner" ]] &&
    [[ "$(readlink "${HOME2}/.config/karabiner")" = "${DEST}/karabiner" ]]; then
    pass "pre-existing .config/karabiner replaced with symlink"
  else
    fail ".config/karabiner was not replaced with the repo symlink"
  fi
  if [[ -f "${HOME2}/.config/karabiner.bak/karabiner.json" ]]; then
    pass "old .config/karabiner backed up to .bak"
  else
    fail "old .config/karabiner was not backed up"
  fi
else
  fail "install.sh failed with a pre-existing .config/karabiner"
fi

echo ""
echo "----------------------------------------"
printf 'Passed: %d  Failed: %d\n' "${PASS}" "${FAIL}"
[[ "${FAIL}" -eq 0 ]] || exit 1
echo "install.sh reproduces all declared links."
