# --- fzf-tab (before widget-wrapping plugins) ---
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview '(bat --color=always --style=plain $realpath 2>/dev/null || eza -1 --color=always --icons=auto $realpath) 2>/dev/null'
zstyle ':fzf-tab:*' switch-group '<' '>'

# --- zsh-abbr ---
ABBR_USER_ABBREVIATIONS_FILE="$HOME/dotfiles/zsh/abbreviations"
ABBR_SET_EXPANSION_CURSOR=1
source /opt/homebrew/share/zsh-abbr/zsh-abbr.zsh

# ---autosuggestions / syntax-highlighting ---
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- history-substring-search (must be last) ---
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
