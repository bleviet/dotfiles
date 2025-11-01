#!/bin/bash

# Script to backup existing dotfiles and stow new configurations using GNU Stow

# Define the stow directory relative to the script's location
STOW_DIR="$(dirname "$0")/../stow"

# Function to backup a file or directory if it exists
backup_item() {
  local item="$1"
  if [ -e "$HOME/$item" ]; then
    echo "Backing up $HOME/$item to $HOME/${item}.bak"
    mv "$HOME/$item" "$HOME/${item}.bak"
  fi
}

# Function to stow a package
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

# Backup bash configuration files
backup_item ".bash_profile"
backup_item ".bashrc"
backup_item ".bashrc.d"

# Backup zsh configuration files
backup_item ".zshrc"
backup_item ".zshrc.d"

# Backup common shell configuration
backup_item ".config/shell"

# Backup LazyVim configuration
backup_item ".config/nvim"
backup_item ".local/share/nvim"
backup_item ".local/state/nvim"
backup_item ".cache/nvim"

# Backup tmux configuration
backup_item ".tmux.conf"

# Change to stow directory
cd "$STOW_DIR" || { echo "Error: Cannot change to stow directory."; exit 1; }

# Stow configurations
stow_package "bash"
stow_package "zsh"
stow_package "common"
stow_package "nvim"
stow_package "tmux"

# Return to original directory
cd - >/dev/null
