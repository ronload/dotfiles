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
    ln -s "$DOTFILES_DIR/$config" "$HOME/.config/$config"
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

# Oh My Zsh custom plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

omz_plugins=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions.git"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting.git"
  "fzf-git-sh:https://github.com/junegunn/fzf-git.sh.git"
)

for entry in "${omz_plugins[@]}"; do
  plugin="${entry%%:*}"
  url="${entry#*:}"
  if [ -d "$ZSH_CUSTOM/plugins/$plugin" ]; then
    echo "✓ $plugin already installed"
  else
    git clone "$url" "$ZSH_CUSTOM/plugins/$plugin"
    echo "✓ Cloned $plugin"
  fi
done

# Zed settings
mkdir -p ~/.config/zed
if [ -L "$HOME/.config/zed/settings.json" ]; then
  echo "✓ zed settings already linked"
else
  ln -s "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
  echo "✓ Linked zed settings"
fi

echo "Dotfiles installed successfully!"
