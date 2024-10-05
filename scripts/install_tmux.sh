#!/bin/bash

# Exit on error
set -e

# Function to print info messages
info() {
  echo "[INFO] $1"
}

# Function to print error messages
error() {
  echo "[ERROR] $1"
  exit 1
}

# Function to print help message
print_help() {
  echo "Usage: $0 [--version <version>] [--help|-h]"
  echo
  echo "Options:"
  echo "  --version <version>  Specify the tmux version to install (default: 3.5a)"
  echo "  --help, -h           Show this help message and exit"
}

# Default tmux version
DEFAULT_TMUX_VERSION="3.5a"
TMUX_VERSION=$DEFAULT_TMUX_VERSION

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
  --version)
    TMUX_VERSION="$2"
    shift
    ;;
  --help | -h)
    print_help
    exit 0
    ;;
  *)
    echo "Unknown parameter passed: $1"
    print_help
    exit 1
    ;;
  esac
  shift
done

# Check if tmux is installed and matches the required version
if command -v tmux &>/dev/null; then
  INSTALLED_VERSION=$(tmux -V | awk '{print $2}')
  if [ "$INSTALLED_VERSION" == "$TMUX_VERSION" ]; then
    info "tmux $TMUX_VERSION is already installed."
    exit 0
  fi
fi

# Install dependencies
info "Updating package lists and installing dependencies..."
sudo apt update
sudo apt install -y automake pkg-config libevent-dev libncurses5-dev build-essential bison || error "Failed to install dependencies."

# Download tmux source code
TMUX_TAR="tmux-${TMUX_VERSION}.tar.gz"
TMUX_URL="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/${TMUX_TAR}"
info "Downloading tmux ${TMUX_VERSION}..."
wget -O "$TMUX_TAR" "$TMUX_URL" || error "Failed to download tmux source."

# Extract the downloaded tarball
info "Extracting tmux source..."
tar -xzf "$TMUX_TAR" || error "Failed to extract tmux source."

# Navigate into the tmux source directory
cd "tmux-${TMUX_VERSION}"

# Compile tmux
info "Compiling tmux..."
./configure || error "Configuration failed."
make || error "Compilation failed."

# Install tmux
info "Installing tmux..."
sudo make install || error "Installation failed."

# Verify tmux installation
info "Verifying tmux installation..."
tmux -V || error "tmux installation verification failed."

# Clean up
info "Cleaning up..."
cd ..
rm -rf "tmux-${TMUX_VERSION}" "$TMUX_TAR"

info "tmux ${TMUX_VERSION} installed successfully!"

# Setup Configuration
cd ../stow/
stow -t $HOME tmux
