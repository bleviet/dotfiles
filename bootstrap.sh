#!/bin/bash
# bootstrap.sh
# Purpose: Detect OS, install minimal dependencies (git, curl, stow, python3), and run install.sh.

set -euo pipefail

echo "========================================="
echo "   Bootstrapping Dotfiles Environment    "
echo "========================================="

# 1. Detect OS
OS_ID="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
elif [ "$(uname)" = "Darwin" ]; then
  OS_ID="macos"
fi

echo "Detected OS: $OS_ID"

# Helper function to run commands as root
run_as_root() {
  if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      sudo "$@"
    else
      echo "Error: root privileges are required to install dependencies but 'sudo' is not available."
      exit 1
    fi
  else
    "$@"
  fi
}

# 2. Install minimal packages based on OS
case "$OS_ID" in
  debian|ubuntu)
    echo "Installing minimal packages via apt..."
    run_as_root apt-get update -y
    run_as_root apt-get install -y git curl stow python3-minimal
    ;;
  rocky|almalinux|centos|rhel)
    echo "Installing minimal packages via dnf..."
    # stow is in EPEL, so enable it first
    run_as_root dnf install -y epel-release
    run_as_root dnf install -y git curl stow python3
    ;;
  macos)
    echo "Checking macOS bootstrap requirements..."
    if ! command -v git >/dev/null 2>&1 || ! command -v stow >/dev/null 2>&1; then
      if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew for dependency installation..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)" || eval "$(/usr/local/bin/brew shellenv)"
      fi
      brew install git stow python
    else
      echo "git and stow already present on macOS."
    fi
    ;;
  *)
    echo "Warning: Unsupported OS '$OS_ID'. Trying to proceed with existing tools..."
    if ! command -v git >/dev/null 2>&1 || ! command -v stow >/dev/null 2>&1; then
      echo "Error: git and stow are required but not installed."
      exit 1
    fi
    ;;
esac

# 3. Launch Second Stage Installer (install.sh)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [ -f "./install.sh" ]; then
  echo "Launching second stage installer (install.sh)..."
  chmod +x ./install.sh
  ./install.sh
elif [ -f "./setup" ]; then
  echo "Launching setup script..."
  chmod +x ./setup
  ./setup
else
  echo "Error: Neither install.sh nor setup script was found!"
  exit 1
fi

echo "========================================="
echo "   Bootstrap Completed Successfully!     "
echo "========================================="
