#!/bin/bash
# scripts/backup_and_stow.sh
# Purpose: backup existing dotfiles and deploy new ones using GNU Stow (core, OS, and host-specific)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Detect OS and Hostname
OS_ID="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
elif [ "$(uname)" = "Darwin" ]; then
  OS_ID="macos"
fi
MY_HOSTNAME="$(hostname)"

echo "========================================="
echo "   Stow Configuration Deployment"
echo "========================================="
echo "Detected OS: $OS_ID"
echo "Hostname: $MY_HOSTNAME"

###############################################################################
# Helpers
###############################################################################
backup_item() {
  local item="$1"
  if [ -e "$HOME/$item" ] && [ ! -L "$HOME/$item" ]; then
    echo "Backing up $HOME/$item to $HOME/${item}.bak"
    mv "$HOME/$item" "$HOME/${item}.bak"
  fi
}

stow_packages() {
  local dir="$1"
  shift
  local packages=("$@")
  echo "Stowing packages [${packages[*]}] from $dir..."
  if stow --no-folding -d "$dir" -t "$HOME" "${packages[@]}"; then
    echo "Stowed successfully."
  else
    echo "Warning: Stow returned an error for folder $dir."
  fi
}

###############################################################################
# Backups (protect existing files from clashing with Stow symlinks)
###############################################################################
echo "Performing backups of existing config files..."
backup_item ".bash_profile"
backup_item ".bashrc"
backup_item ".bashrc.d"
backup_item ".zshrc"
backup_item ".zshrc.d"
backup_item ".config/shell"
backup_item ".config/nvim"
backup_item ".tmux.conf"

###############################################################################
# Stow deploy
###############################################################################
# 1. Stow Core packages
stow_packages "$ROOT_DIR/core" bash zsh common nvim tmux

# 2. Stow OS-specific packages
if [ -d "$ROOT_DIR/os/$OS_ID" ]; then
  echo "OS-specific configuration folder found for '$OS_ID'."
  stow_packages "$ROOT_DIR/os/$OS_ID" common
else
  echo "No OS-specific folder found for '$OS_ID'. Skipping."
fi

# 3. Stow Host-specific packages
if [ -d "$ROOT_DIR/host/$MY_HOSTNAME" ]; then
  echo "Host-specific configuration folder found for '$MY_HOSTNAME'."
  stow_packages "$ROOT_DIR/host/$MY_HOSTNAME" common
else
  # Provide fallback laptop/workstation matching logic if hostname is generic
  echo "No host-specific folder found for exact hostname '$MY_HOSTNAME'."
fi

echo "Stow deployment finished."
