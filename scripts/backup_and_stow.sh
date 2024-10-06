#!/bin/bash

# Backup and stow bash configuration files
[ -f $HOME/.bash_profile ] && mv $HOME/.bash_profile{,.bak}
[ -f $HOME/.bashrc ] && mv $HOME/.bashrc{,.bak}
[ -d $HOME/.bashrc.d ] && mv $HOME/.bashrc.d{,.bak}

# Backup LazyVim configuration
[ -d $HOME/.config/nvim ] && mv $HOME/.config/nvim{,.bak}
[ -d $HOME/.local/share/nvim ] && mv $HOME/.local/share/nvim{,.bak}
[ -d $HOME/.local/state/nvim ] && mv $HOME/.local/state/nvim{,.bak}
[ -d $HOME/.cache/nvim ] && mv $HOME/.cache/nvim{,.bak}

# Backup tmux configuration
[ -f $HOME/.tmux.conf ] && mv $HOME/.tmux.conf{,.bak}

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
