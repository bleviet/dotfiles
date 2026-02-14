#!/bin/bash

set -euo pipefail

###############################################################################
# scripts/backup_and_stow.sh
# Purpose: backup existing dotfiles and deploy new ones using GNU Stow
###############################################################################

# Define the stow directory relative to the script's location
STOW_DIR="$(dirname "$0")/../stow"

###############################################################################
# Helpers
###############################################################################
backup_item() {
  local item="$1"
  if [ -e "$HOME/$item" ]; then
    echo "Backing up $HOME/$item to $HOME/${item}.bak"
    mv "$HOME/$item" "$HOME/${item}.bak"
  fi
}

stow_package() {
  local package="$1"
  echo "Stowing $package configuration..."
  if stow -t "$HOME" "$package"; then
    echo "$package stowed successfully."
  else
    echo "Error: Failed to stow $package."
    return 1
  fi
}

###############################################################################
# Backup list
###############################################################################
backup_item ".bash_profile"
backup_item ".bashrc"
backup_item ".bashrc.d"

backup_item ".zshrc"
backup_item ".zshrc.d"

backup_item ".config/shell"

backup_item ".config/nvim"
backup_item ".local/share/nvim"
backup_item ".local/state/nvim"
backup_item ".cache/nvim"

backup_item ".tmux.conf"

###############################################################################
# Stow
###############################################################################
cd "$STOW_DIR" || { echo "Error: Cannot change to stow directory."; exit 1; }

stow_package "bash"
stow_package "zsh"
stow_package "common"
stow_package "nvim"
stow_package "tmux"

# Return to original directory
cd - >/dev/null
