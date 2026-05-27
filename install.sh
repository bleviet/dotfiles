#!/bin/bash
# install.sh
# Purpose: orchestrate local setup steps (feature flags, system deps, fonts, brew, stow)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"

echo "========================================="
echo "   Installing Dotfiles Configuration     "
echo "========================================="

# 1. Detect OS
OS_ID="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
elif [ "$(uname)" = "Darwin" ]; then
  OS_ID="macos"
fi

# 2. Automated Feature Flag Provisioning
if [ ! -f "$HOME/.dotfiles.local" ]; then
  echo "Generating default ~/.dotfiles.local..."
  IS_GUI=1
  # Check if in a non-graphical terminal, container or headless
  if [[ -f /.dockerenv ]] || [[ -n "${DEBIAN_FRONTEND:-}" ]] || [[ -z "${DISPLAY:-}" ]]; then
    IS_GUI=0
  fi
  cat <<EOL > "$HOME/.dotfiles.local"
# Local Dotfiles Configuration & Feature Flags
export DOTFILES_FEATURE_GUI=$IS_GUI
export DOTFILES_FEATURE_FPGATOOLS=0
EOL
  echo "Default feature flags set: GUI=$IS_GUI, FPGATOOLS=0"
fi

# Load feature flags
source "$HOME/.dotfiles.local"

# Helper to run scripts safely
run_step() {
  local script="$1"
  echo "Running $script..."
  bash "$SCRIPTS_DIR/$script"
}

# 3. System dependency installation
run_step install_dependencies.sh

# 4. Install Nerd Fonts (only if GUI is enabled)
run_step install_nerdfonts.sh

# 5. Homebrew installation
run_step install_brew.sh

# 6. Load Homebrew environment into current installer shell
if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -x "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x "/usr/local/bin/brew" ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# 7. Install Homebrew packages (if brew is present)
if command -v brew >/dev/null 2>&1; then
  PACKAGES=(
    rust
    neovim
    fd
    fzf
    ripgrep
    lazygit
    node
    pyright
    uv
    eza
    starship
    tmux
    yazi
    zoxide
  )

  echo "Installing Homebrew packages: ${PACKAGES[*]}"
  for pkg in "${PACKAGES[@]}"; do
    if ! brew list --formula | grep -q "^${pkg}$" && ! brew list --cask | grep -q "^${pkg}$"; then
      echo "- installing $pkg"
      brew install "$pkg" || echo "Warning: failed to install $pkg"
    else
      echo "- $pkg already installed, skipping"
    fi
  done
else
  echo "Homebrew not found; skipping brew packages."
fi

# 8. Setup Git and Deploy Symlinks via Stow
run_step setup_gitconfig.sh
run_step backup_and_stow.sh

echo "========================================="
echo "   Dotfiles Installation Complete!       "
echo "========================================="
