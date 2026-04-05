# dotfiles

Personal configuration files for my development environment.

## Installation

```bash
# Clone the repo
git clone https://github.com/ronload/dotfiles.git ~/dotfiles

# Run install script
cd ~/dotfiles
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
