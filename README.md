# dotfiles

Personal configuration files for my development environment.

## Setup on a New Machine

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Clone this repo
git clone https://github.com/ronload/dotfiles.git ~/dotfiles

# 3. Install packages
cd ~/dotfiles
brew bundle install

# 4. Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Install Rust toolchain
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 6. Run install script (symlinks + zsh plugins + nvim plugin sync)
./install.sh
```

## Included Configs

- **nvim**: Neovim with lazy.nvim
- **ghostty**: Ghostty terminal
- **zsh**: Zsh shell (zshrc, zprofile, zshenv)
- **zed**: Zed editor
- **gh**: GitHub CLI
- **git**: Git global config
- **brew**: Brewfile for Homebrew packages

## Manual Setup

If you prefer manual installation:

```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/ghostty ~/.config/ghostty
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json
ln -s ~/dotfiles/gh ~/.config/gh
ln -sf ~/dotfiles/git/gitconfig ~/.gitconfig
ln -sf ~/dotfiles/git/ignore ~/.gitignore_global
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh/zprofile ~/.zprofile
ln -sf ~/dotfiles/zsh/zshenv ~/.zshenv
```
