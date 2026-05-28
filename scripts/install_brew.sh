#!/bin/bash
# scripts/install_brew.sh
# Purpose: install Homebrew build dependencies and Homebrew itself

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=scripts/lib.sh
source "$ROOT_DIR/scripts/lib.sh"

OS_ID="$(detect_os)"

is_brew_installed() {
  command -v brew >/dev/null 2>&1 || \
    [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] || \
    [ -x "/opt/homebrew/bin/brew" ] || \
    [ -x "/usr/local/bin/brew" ]
}

install_brew() {
  echo "Installing Homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null; then
    if [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ -x "/opt/homebrew/bin/brew" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo "Homebrew installation complete!"
    return 0
  else
    echo "Error: Failed to install Homebrew."
    return 1
  fi
}

verify_brew() {
  echo "Verifying Homebrew installation..."
  if brew --version; then
    echo "Homebrew is ready to use!"
  else
    echo "Error: Homebrew verification failed."
    return 1
  fi
}

if is_brew_installed; then
  echo "Homebrew is already installed."
else
  echo "Installing build dependencies for Homebrew..."
  python3 "$ROOT_DIR/packages/install.py" --group brew-build-deps
  if install_brew; then
    verify_brew
  fi
fi
