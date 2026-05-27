#!/bin/bash
# scripts/install_brew.sh
# Purpose: ensure system deps and install Homebrew when necessary cross-platform

set -euo pipefail

OS_ID="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
elif [ "$(uname)" = "Darwin" ]; then
  OS_ID="macos"
fi

run_as_root() {
  if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      sudo "$@"
    else
      echo "Error: root privileges are required to install brew system dependencies but 'sudo' is not available."
      exit 1
    fi
  else
    "$@"
  fi
}

install_system_build_deps() {
  echo "Installing system build dependencies..."
  case "$OS_ID" in
    debian|ubuntu)
      run_as_root apt-get update -y
      run_as_root apt-get install -y build-essential curl file git
      ;;
    rocky|almalinux|centos|rhel)
      run_as_root dnf groupinstall -y "Development Tools"
      run_as_root dnf install -y curl file git
      ;;
    macos)
      echo "macOS: build tools are typically included in Xcode Command Line Tools. Skipping system packages."
      ;;
    *)
      echo "Unknown OS. Skipping build dependencies installation..."
      ;;
  esac
}

is_brew_installed() {
  command -v brew >/dev/null 2>&1 || \
    [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ] || \
    [ -x "/opt/homebrew/bin/brew" ] || \
    [ -x "/usr/local/bin/brew" ]
}

install_brew() {
  echo "Installing Homebrew..."
  # Run the official Homebrew install script non-interactively
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" < /dev/null; then
    # Add Homebrew to current shell context for verification
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

###############################################################################
# Main
###############################################################################
if is_brew_installed; then
  echo "Homebrew is already installed."
else
  install_system_build_deps
  if install_brew; then
    verify_brew
  fi
fi
