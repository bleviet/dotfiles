#!/bin/bash

set -euo pipefail

###############################################################################
# scripts/install_brew.sh
# Purpose: ensure system deps and install Homebrew when necessary
###############################################################################

###############################################################################
# System update
###############################################################################
update_system() {
  echo "Updating system package lists..."
  if ! sudo apt update -y; then
    echo "Error: Failed to update system packages."
    return 1
  fi
}

###############################################################################
# Install minimal build dependencies
###############################################################################
install_dependencies() {
  echo "Installing required dependencies..."
  if ! sudo apt install -y build-essential curl file git; then
    echo "Error: Failed to install dependencies."
    return 1
  fi
}

###############################################################################
# Homebrew helpers
###############################################################################
is_brew_installed() {
  command -v brew >/dev/null 2>&1
}

install_brew() {
  echo "Installing Homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
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

###############################################################################
# Main
###############################################################################
update_system || exit 1
install_dependencies || exit 1

if is_brew_installed; then
  echo "Homebrew is already installed."
else
  if install_brew; then
    verify_brew
  fi
fi
