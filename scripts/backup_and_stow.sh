#!/bin/bash

# Backup and stow bash configuration files
echo "Backing up bash configuration files..."
mv $HOME/.bash_profile{,.bak}
mv $HOME/.bashrc{,.bak}
mv $HOME/.bashrc.d{,.bak}

# Backup LazyVim configuration
echo "Backing up LazyVim configuration..."
# required
mv $HOME/.config/nvim{,.bak}

# optional but recommended
mv $HOME/.local/share/nvim{,.bak}
mv $HOME/.local/state/nvim{,.bak}
mv $HOME/.cache/nvim{,.bak}

# Backup tmux configuration
echo "Backing up tmux configuration..."
mv $HOME/.tmux.conf{,.bak}

cd ../stow
# Stow bash configuration files
echo "Stowing bash configuration files..."
stow -t $HOME bash

# Stow LazyVim configuration
echo "Stowing LazyVim configuration..."
stow -t $HOME nvim

# Stow tmux configuration
echo "Stowing tmux configuration..."
stow -t $HOME tmux
