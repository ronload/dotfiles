# editor
alias vi='nvim'
alias vim='nvim'

# git
alias gs='git status --short'
alias ga='git add'
alias gsm='git switch main'
alias gsc='git switch -c'
alias gpcm='gh pr create --base main'

# tools
run() { chmod +x "$1" && ./"$1"; }
alias p="pnpm"
alias :q="exit"
alias countcode="tokei . -e node_modules -e .venv -e .next -e dist -e build -e out"

# navigation
alias ..="cd .."
alias dotfiles="cd ~/dotfiles/"
alias proj="cd ~/working/projects/"
