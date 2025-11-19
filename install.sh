#!/bin/bash
set -e
echo "Installing dotfiles..."
mkdir -p ~/.config

# Symlink configs in .config directory
configs=(
  "nvim"
  "wezterm"
  "gh"
)

for config in "${configs[@]}"; do
  if [ -L "$HOME/.config/$config" ]; then
    echo "✓ $config already linked"
  else
    ln -s "$HOME/dotfiles/$config" "$HOME/.config/$config"
    echo "✓ Linked $config"
  fi
done

# Git configuration (special case - goes in home directory)
if [ -L "$HOME/.gitconfig" ]; then
  echo "✓ .gitconfig already linked"
else
  ln -sf "$HOME/dotfiles/git/gitconfig" "$HOME/.gitconfig"
  echo "✓ Linked .gitconfig"
fi

# Git ignore file
if [ -L "$HOME/.gitignore_global" ]; then
  echo "✓ .gitignore_global already linked"
else
  ln -sf "$HOME/dotfiles/git/ignore" "$HOME/.gitignore_global"
  echo "✓ Linked .gitignore_global"
fi

# Zed settings
mkdir -p ~/.config/zed
if [ -L "$HOME/.config/zed/settings.json" ]; then
  echo "✓ zed settings already linked"
else
  ln -s "$HOME/dotfiles/zed/settings.json" "$HOME/.config/zed/settings.json"
  echo "✓ Linked zed settings"
fi

echo "Dotfiles installed successfully!"
