autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr ' *'
zstyle ':vcs_info:git:*' stagedstr ' *'
zstyle ':vcs_info:git:*' formats ' %F{blue}%b%f%F{yellow}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}%b%f%F{red}|%a%f%F{yellow}%u%c%f'
precmd() { vcs_info }
setopt PROMPT_SUBST
PROMPT='%B%F{magenta} %c%f${vcs_info_msg_0_}%b '

