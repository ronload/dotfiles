# git
glb() {
  local branch=$(pbpaste | sed 's|^[^/]*/||')
  git switch --create "$1/$branch"
}

# tools
run() { chmod +x "$1" && ./"$1"; }
alias cat="bat"
alias fastfetch="macchina"
alias http="xh"
alias https="xhs"
alias jq="jaq"
alias top="btm"
alias vi='nvim'
alias vim='nvim'

# eza
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first --time-style=relative'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lr='eza -l --icons=auto --git --sort=modified --time-style=relative'
alias lf='eza --tree --level=3 --icons=auto --git-ignore | fzf --preview "bat --color=always {}"'
alias lgit='eza -la --icons=auto --git --git-ignore --group-directories-first'
