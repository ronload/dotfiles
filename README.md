<p align="center">
  <img src="assets/readme-banner.png" alt="dotfiles banner" />
</p>

# dotfiles

[![License](https://img.shields.io/github/license/ronload/dotfiles?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS-lightgrey?style=flat-square)](https://www.apple.com/macos)
[![shellcheck](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/shellcheck.yml?branch=main&label=shellcheck&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/shellcheck.yml)
[![shfmt](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/shfmt.yml?branch=main&label=shfmt&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/shfmt.yml)
[![zsh-syntax](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/zsh-syntax.yml?branch=main&label=zsh-syntax&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/zsh-syntax.yml)
[![lua-lint](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/lua-lint.yml?branch=main&label=lua-lint&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/lua-lint.yml)
[![stylua](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/stylua.yml?branch=main&label=stylua&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/stylua.yml)
[![gitleaks](https://img.shields.io/github/actions/workflow/status/ronload/dotfiles/gitleaks.yml?branch=main&label=gitleaks&style=flat-square)](https://github.com/ronload/dotfiles/actions/workflows/gitleaks.yml)
[![Theme](https://img.shields.io/badge/theme-TokyoNight%20Moon-82aaff?style=flat-square)](https://github.com/folke/tokyonight.nvim)

Personal configuration files for my macOS development environment, centered on Neovim, Zsh, and Ghostty.

## Requirements

- macOS
- No other prerequisites — `setup.sh` installs Homebrew and everything else from `Brewfile`.

## Quick Start

```bash
git clone https://github.com/ronload/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` installs Homebrew, Rust, [opencode](https://opencode.ai), and every package in `Brewfile`, then hands off to `install.sh` to symlink configs, clone `fzf-git.sh`, and sync Neovim plugins. Each step is idempotent and safe to re-run.

## What's Included

- **nvim**: Neovim with lazy.nvim and TokyoNight Moon
- **zsh**: Zsh shell (zshrc, zprofile, zshenv, aliases, prompt, abbreviations)
- **ghostty**: Ghostty terminal
- **git**: Git global config (with conditional work identity include)
- **gh**: GitHub CLI
- **fastfetch**: System info with a custom colored-bar module
- **karabiner**: Karabiner-Elements keyboard customization
- **yazi**: Terminal file manager
- **Brewfile**: Homebrew package manifest

## Development

Linting and formatting are driven by [`just`](https://github.com/casey/just). The `justfile` is the single source of truth — GitHub Actions invoke the same recipes on every push and pull request.

```bash
just              # list all recipes
just ci           # run every linter and formatter check
just lint         # run all linters (lua, shell, zsh)
just format       # run all formatter checks (lua, shell)
just lint-lua     # luacheck on tracked Lua files
just lint-shell   # shellcheck on tracked shell scripts
just lint-zsh     # zsh -n syntax check on zsh/*
just format-lua   # stylua --check
just format-shell # shfmt -i 2 -ci -d
just test         # run all tests
just test-install # verify install.sh reproduces every declared symlink
```

All linter recipes operate on `git ls-files`, so untracked files are skipped. Zsh files are validated by `zsh -n` rather than shellcheck, which does not support zsh.

## Reproduction Tests

Two layers verify that a fresh install reproduces the environment:

- **`install.sh` linking** (`just test-install`, runs on every PR via [`install-test.yml`](.github/workflows/install-test.yml)): runs `install.sh` against a disposable copy of the repo and a sandbox `$HOME`, then asserts every declared symlink exists, points at the right target, is not broken, and that a second run re-links nothing. Fully offline and isolated; touches neither the real working tree nor the real home directory.
- **Full `setup.sh` end-to-end** ([`e2e-macos.yml`](.github/workflows/e2e-macos.yml), scheduled weekly + manual + on changes to `setup.sh`/`install.sh`/`Brewfile`): runs the whole `setup.sh` on a macOS runner, installing every `Brewfile` package, then re-runs the link check. GUI casks are skipped via `HOMEBREW_BUNDLE_CASK_SKIP` because they cannot be verified headless.

Hosted runners are not a truly pristine macOS (Homebrew, git, go and rust come pre-installed), so the e2e job approximates rather than guarantees a fresh-machine install. A real fresh-install guarantee would need a macOS VM (tart/UTM) on a self-hosted runner.

### Repo location and Karabiner

Two details make reproduction location-independent and Karabiner-safe:

- Several configs reference the repo by the absolute path `~/dotfiles` (tmux, git, ghostty, fastfetch, zsh), and those tools cannot resolve the path dynamically. `install.sh` therefore ensures `~/dotfiles` points at the repo, so it can be cloned anywhere; cloning to `~/dotfiles` directly needs no extra link. An existing real `~/dotfiles` that is not this repo is left untouched and the install aborts.
- `~/.config/karabiner` is symlinked as a whole directory rather than just `karabiner.json`, because Karabiner-Elements replaces a symlinked config file on save (per its [docs](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/)). A pre-existing real config directory is backed up to `.bak` before linking.

## Local Overrides

`git/gitconfig` conditionally includes a work identity for repos under `git@github.com:prinsur/**`:

```gitconfig
[includeIf "hasconfig:remote.*.url:git@github.com:prinsur/**"]
    path = ~/.gitconfig-prinsur
```

This override file is not tracked. Create it manually on each machine:

```bash
cat > ~/.gitconfig-prinsur <<'EOF'
[user]
    email = your-work-email@example.com
EOF
```

Without it, commits to `prinsur/*` repos fall back to the global identity.

## License

Released under the MIT License. See [LICENSE](LICENSE) for details.
