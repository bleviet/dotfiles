#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install recommended tools for lazyvim
bash install_rust.sh
bash install_neovim.sh
bash install_nerdfonts.sh
bash install_fd.sh
bash install_ripgrep.sh
bash install_lazygit.sh

# Stow lazyvim configuration
cd ../stow
stow -t $HOME nvim
