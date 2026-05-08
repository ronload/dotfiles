# editor
alias vi='nvim'
alias vim='nvim'

# git
alias gsm='git switch main'
alias gsc='git switch -c'
alias gpcm='gh pr create --base main'
glb() {
  local branch=$(pbpaste | sed 's|^[^/]*/||')
  git checkout -b "$1/$branch"
}

# tools
run() { chmod +x "$1" && ./"$1"; }
alias p="pnpm"
alias :q="exit"
alias countcode="tokei . -e node_modules -e .venv -e .next -e dist -e build -e out"
alias c=claude
alias cat="bat"
alias http="xh"
alias https="xhs"

# eza
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lr='eza -l --icons=auto --git --sort=modified --time-style=relative'
alias lt='eza --tree --level=2 --icons=auto --git-ignore'
alias lt3='eza --tree --level=3 --icons=auto --git-ignore'
alias lgit='eza -la --icons=auto --git --git-ignore --group-directories-first'
alias lf='eza --tree --level=3 --icons=auto --git-ignore | fzf --preview "bat --color=always {}"'

# navigation
alias ..="cd .."
alias dotfiles="cd ~/dotfiles/"
alias proj="cd ~/working/projects/"
alias desktop="~/Desktop/"
