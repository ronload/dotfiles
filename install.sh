#!/bin/bash
set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "Installing dotfiles..."
mkdir -p ~/.config

# Symlink configs in .config directory
configs=(
  "nvim"
  "gh"
  "ghostty"
)

for config in "${configs[@]}"; do
  if [ -L "$HOME/.config/$config" ]; then
    echo "✓ $config already linked"
  else
    ln -sf "$DOTFILES_DIR/$config" "$HOME/.config/$config"
    echo "✓ Linked $config"
  fi
done

# Git configuration (special case - goes in home directory)
if [ -L "$HOME/.gitconfig" ]; then
  echo "✓ .gitconfig already linked"
else
  ln -sf "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"
  echo "✓ Linked .gitconfig"
fi

# Git ignore file
if [ -L "$HOME/.gitignore_global" ]; then
  echo "✓ .gitignore_global already linked"
else
  ln -sf "$DOTFILES_DIR/git/ignore" "$HOME/.gitignore_global"
  echo "✓ Linked .gitignore_global"
fi

# Shell configuration (symlink to home directory)
shell_configs=(
  "zshrc:.zshrc"
  "zprofile:.zprofile"
  "zshenv:.zshenv"
)

for entry in "${shell_configs[@]}"; do
  src="${entry%%:*}"
  dest="${entry##*:}"
  if [ -L "$HOME/$dest" ]; then
    echo "✓ $dest already linked"
  else
    ln -sf "$DOTFILES_DIR/zsh/$src" "$HOME/$dest"
    echo "✓ Linked $dest"
  fi
done

# Zed settings
mkdir -p ~/.config/zed
if [ -L "$HOME/.config/zed/settings.json" ]; then
  echo "✓ zed settings already linked"
else
  ln -sf "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
  echo "✓ Linked zed settings"
fi

# Claude Code configuration
mkdir -p "$HOME/.claude"
claude_files=(
  "CLAUDE.md"
  "settings.json"
  "statusline.sh"
)
for file in "${claude_files[@]}"; do
  if [ -L "$HOME/.claude/$file" ]; then
    echo "✓ claude/$file already linked"
  else
    ln -sf "$DOTFILES_DIR/claude/$file" "$HOME/.claude/$file"
    echo "✓ Linked claude/$file"
  fi
done

# Claude Code skills (link each skill individually, ~/.claude/skills/ may have other content)
mkdir -p "$HOME/.claude/skills"
for skill_dir in "$DOTFILES_DIR/claude/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  if [ -L "$HOME/.claude/skills/$skill_name" ]; then
    echo "✓ claude/skills/$skill_name already linked"
  else
    ln -sf "$skill_dir" "$HOME/.claude/skills/$skill_name"
    echo "✓ Linked claude/skills/$skill_name"
  fi
done

# Claude Code hooks (link each hook individually, ~/.claude/hooks/ may have other content)
mkdir -p "$HOME/.claude/hooks"
for hook_file in "$DOTFILES_DIR/claude/hooks"/*.sh; do
  [ -f "$hook_file" ] || continue
  hook_name="$(basename "$hook_file")"
  if [ -L "$HOME/.claude/hooks/$hook_name" ]; then
    echo "✓ claude/hooks/$hook_name already linked"
  else
    ln -sf "$hook_file" "$HOME/.claude/hooks/$hook_name"
    echo "✓ Linked claude/hooks/$hook_name"
  fi
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
