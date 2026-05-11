#!/bin/bash
set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing dotfiles..."
mkdir -p ~/.config

# link_file <src> <dest>
# Creates a symlink dest -> src, replacing any existing symlink with the
# wrong target. Reports already-linked when target matches.
link_file() {
  local src="$1" dest="$2"
  local label="${dest/#$HOME/~}"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "✓ $label already linked"
  else
    ln -sfn "$src" "$dest"
    echo "✓ Linked $label"
  fi
}

# Symlink configs in .config directory
configs=(
  "nvim"
  "gh"
  "ghostty"
)

for config in "${configs[@]}"; do
  link_file "$DOTFILES_DIR/$config" "$HOME/.config/$config"
done

# Git configuration (special case - goes in home directory)
link_file "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# Git ignore file
link_file "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"

# Shell configuration (symlink to home directory)
shell_configs=(
  "zshrc:.zshrc"
  "zprofile:.zprofile"
  "zshenv:.zshenv"
)

for entry in "${shell_configs[@]}"; do
  shell_src="${entry%%:*}"
  shell_dest="${entry##*:}"
  link_file "$DOTFILES_DIR/zsh/$shell_src" "$HOME/$shell_dest"
done

# Zed settings
mkdir -p ~/.config/zed
link_file "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"

# Claude Code configuration
mkdir -p "$HOME/.claude"
claude_files=(
  "CLAUDE.md"
  "settings.json"
  "statusline.sh"
)
for file in "${claude_files[@]}"; do
  link_file "$DOTFILES_DIR/claude/$file" "$HOME/.claude/$file"
done

# Claude Code skills (link each skill individually, ~/.claude/skills/ may have other content)
mkdir -p "$HOME/.claude/skills"
for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  link_file "$skill_dir" "$HOME/.claude/skills/$skill_name"
done

# Claude Code hooks (link each hook individually, ~/.claude/hooks/ may have other content)
mkdir -p "$HOME/.claude/hooks"
for hook_file in "$DOTFILES_DIR/claude/hooks"/*.sh; do
  [ -f "$hook_file" ] || continue
  hook_name="$(basename "$hook_file")"
  link_file "$hook_file" "$HOME/.claude/hooks/$hook_name"
done

# fzf-git.sh (sourced by zshrc; no Homebrew formula available)
FZF_GIT_DIR="$HOME/.local/share/fzf-git.sh"
if [ -d "$FZF_GIT_DIR" ]; then
  echo "✓ fzf-git.sh already installed"
else
  mkdir -p "$(dirname "$FZF_GIT_DIR")"
  git clone --depth 1 https://github.com/junegunn/fzf-git.sh.git "$FZF_GIT_DIR"
  echo "✓ Cloned fzf-git.sh"
fi

# Sync Neovim plugins (downloads tokyonight.nvim theme used by ghostty and delta)
if command -v nvim &>/dev/null; then
  echo "Syncing Neovim plugins..."
  nvim --headless "+Lazy! sync" +qa
  echo "✓ Neovim plugins synced"
fi

echo "Dotfiles installed successfully!"
