# --- fzf-tab (before widget-wrapping plugins) ---
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=auto $realpath'
zstyle ':fzf-tab:complete:*:*' fzf-preview '(bat --color=always --style=plain $realpath 2>/dev/null || eza -1 --color=always --icons=auto $realpath) 2>/dev/null'
zstyle ':fzf-tab:*' switch-group '<' '>'
# fzf-tab clears FZF_DEFAULT_OPTS, so apply the shared Telescope-style flags (defined in zshrc)
# via fzf-flags. The trailing --layout=reverse wins over the array's --layout=default, putting
# fzf-tab's input box on TOP (the standalone pickers keep input at the bottom via FZF_DEFAULT_OPTS).
zstyle ':fzf-tab:*' fzf-flags "${_fzf_telescope_style[@]}" --layout=reverse
# Keep a Telescope-like fixed height so the three bordered panels always have room
# (fzf-tab otherwise shrinks to content height, which clips the panels for short lists).
zstyle ':fzf-tab:*' fzf-min-height 14

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
