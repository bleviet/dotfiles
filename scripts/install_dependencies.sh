#!/bin/bash
# scripts/install_dependencies.sh
# Purpose: install minimal packages required by setup and tests cross-platform

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
      echo "Error: root privileges are required to install dependencies but 'sudo' is not available."
      exit 1
    fi
  else
    "$@"
  fi
}

echo "Installing dependencies for OS: $OS_ID..."

case "$OS_ID" in
  debian|ubuntu)
    echo "Running apt package installer..."
    run_as_root apt-get update -y
    run_as_root apt-get install -y \
      bat \
      curl \
      file \
      fontconfig \
      git \
      procps \
      stow \
      unzip \
      p7zip-full \
      wget \
      xclip
    ;;
  rocky|almalinux|centos|rhel)
    echo "Running dnf package installer (EPEL will be enabled)..."
    run_as_root dnf install -y epel-release
    run_as_root dnf install -y \
      bat \
      curl \
      file \
      fontconfig \
      git \
      procps \
      stow \
      unzip \
      p7zip \
      wget \
      xclip
    ;;
  macos)
    echo "macOS detected. Skipping system package installation (handled by Homebrew)."
    ;;
  *)
    echo "Unsupported OS '$OS_ID'. Skipping system dependencies install."
    ;;
esac

echo "System dependencies installed successfully."
