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

- **nvim**: Neovim with LazyVim
- **wezterm**: Terminal emulator
- **zed**: Zed editor
- **gh**: GitHub CLI
- **git**: Git global config

## Manual Setup

If you prefer manual installation:
```bash
ln -s ~/dotfiles/nvim ~/.config/nvim
ln -s ~/dotfiles/wezterm ~/.config/wezterm
ln -s ~/dotfiles/zed/settings.json ~/.config/zed/settings.json
ln -s ~/dotfiles/gh ~/.config/gh
ln -s ~/dotfiles/git ~/.config/git
```
