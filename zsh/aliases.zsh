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

# navigation
alias ..="cd .."
alias dotfiles="cd ~/dotfiles/"
alias proj="cd ~/working/projects/"
alias desktop="~/Desktop/"
