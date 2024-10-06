#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install recommended tools for lazyvim
source install_rust.sh
source install_neovim.sh
source install_nerdfonts.sh
source install_fd.sh
source install_ripgrep.sh
source install_lazygit.sh
source install_nodejs.sh

# Install pyright
sudo npm install -g pyright
