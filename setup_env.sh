#!/bin/bash

cd scripts

# Install essential dependencies
source install_dependencies.sh
source install_nerdfonts.sh
source install_brew.sh

# Lazyvim bundle
brew install rust
brew install neovim
brew install fd
brew install fzf
brew install ripgrep
brew install lazygit
brew install node
brew install pyright

# Bash utilities
brew install tmux
brew install nnn
brew install zoxide

# Personal configurations
source setup_gitconfig.sh
source backup_and_stow.sh
