# dotfiles

Personal configuration files for my development environment.

## Setup on a New Machine

```bash
git clone https://github.com/ronload/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` will automatically install Homebrew, Rust, Brewfile packages, Oh My Zsh, then run `install.sh` for symlinks, zsh plugins, and Neovim plugin sync. Each step is guarded so it can be safely re-run.

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
