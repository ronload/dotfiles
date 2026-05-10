# git
glb() {
  local branch=$(pbpaste | sed 's|^[^/]*/||')
  git checkout -b "$1/$branch"
}

# tools
run() { chmod +x "$1" && ./"$1"; }
alias c=claude
alias cat="bat"
alias jq="jaq"
alias http="xh"
alias https="xhs"
alias vi='nvim'
alias vim='nvim'

# eza
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lr='eza -l --icons=auto --git --sort=modified --time-style=relative'
alias lt='eza --tree --level=2 --icons=auto --git-ignore'
alias lt3='eza --tree --level=3 --icons=auto --git-ignore'
alias lgit='eza -la --icons=auto --git --git-ignore --group-directories-first'
alias lf='eza --tree --level=3 --icons=auto --git-ignore | fzf --preview "bat --color=always {}"'

