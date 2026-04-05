#!/bin/bash
set -e
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
TOTAL_STEPS=5
CURRENT_STEP=0

# --- Spinner ---
SPINNER_FRAMES=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
SPINNER_PID=""

spinner_start() {
  local msg="$1"
  (
    i=0
    while true; do
      printf "\r  %s %s" "${SPINNER_FRAMES[$((i % ${#SPINNER_FRAMES[@]}))]}" "$msg"
      i=$((i + 1))
      sleep 0.08
    done
  ) &
  SPINNER_PID=$!
}

spinner_stop() {
  local msg="$1"
  kill "$SPINNER_PID" 2>/dev/null || true
  wait "$SPINNER_PID" 2>/dev/null || true
  SPINNER_PID=""
  printf "\r\033[K  ✓ %s\n" "$msg"
}

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo ""
  echo "[$CURRENT_STEP/$TOTAL_STEPS] $1"
}

# --- Cleanup on exit ---
cleanup() {
  if [ -n "$SPINNER_PID" ]; then
    kill "$SPINNER_PID" 2>/dev/null || true
    wait "$SPINNER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo ""
echo "  Setting up development environment..."

# --- Homebrew ---
step "Homebrew"
if ! command -v brew &>/dev/null; then
  spinner_start "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null
  eval "$(/opt/homebrew/bin/brew shellenv)"
  spinner_stop "Homebrew installed"
else
  echo "  ✓ Homebrew already installed"
fi

# --- Rust ---
step "Rust"
if ! command -v cargo &>/dev/null; then
  spinner_start "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>/dev/null
  source "$HOME/.cargo/env"
  spinner_stop "Rust toolchain installed"
else
  echo "  ✓ Rust already installed"
fi

# --- Brew packages ---
step "Packages"
BREW_CURRENT=0
PREV_TYPE=""

while IFS= read -r line; do
  # Stop previous spinner if running
  if [ -n "$SPINNER_PID" ]; then
    kill "$SPINNER_PID" 2>/dev/null || true
    wait "$SPINNER_PID" 2>/dev/null || true
    SPINNER_PID=""
    if [ "$PREV_TYPE" = "fetch" ]; then
      printf "\r\033[K"
    else
      printf "\r\033[K  ✓ %s\n" "$PREV_NAME"
    fi
  fi

  case "$line" in
    Fetching*)
      spinner_start "Fetching ${line#Fetching }..."
      PREV_NAME="${line#Fetching }"
      PREV_TYPE="fetch"
      ;;
    Installing*)
      BREW_CURRENT=$((BREW_CURRENT + 1))
      PREV_NAME="${line#Installing }"
      spinner_start "Installing $PREV_NAME..."
      PREV_TYPE="install"
      ;;
    Using*|Skipping*)
      BREW_CURRENT=$((BREW_CURRENT + 1))
      printf "  ✓ %s\n" "${line#* }"
      PREV_NAME=""
      PREV_TYPE=""
      ;;
  esac
done < <(brew bundle install --file="$DOTFILES_DIR/Brewfile" 2>&1)

# Stop final spinner if still running
if [ -n "$SPINNER_PID" ]; then
  kill "$SPINNER_PID" 2>/dev/null || true
  wait "$SPINNER_PID" 2>/dev/null || true
  SPINNER_PID=""
  if [ "$PREV_TYPE" != "fetch" ]; then
    printf "\r\033[K  ✓ %s\n" "$PREV_NAME"
  else
    printf "\r\033[K"
  fi
fi
printf "  ✓ All %d packages installed\n" "$BREW_CURRENT"

# --- Oh My Zsh ---
step "Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  spinner_start "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &>/dev/null
  spinner_stop "Oh My Zsh installed"
else
  echo "  ✓ Oh My Zsh already installed"
fi

# --- Dotfiles ---
step "Dotfiles"
spinner_start "Linking configs and syncing plugins..."
"$DOTFILES_DIR/install.sh" &>/dev/null
spinner_stop "Configs linked and plugins synced"

echo ""
echo "  Setup complete!"
echo ""
