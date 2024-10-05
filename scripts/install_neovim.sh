#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install ninja-build gettext cmake unzip curl build-essential

# Clone the Neovim repository
git clone https://github.com/neovim/neovim
cd neovim

# Checkout the latest stable version (optional)
git checkout stable

# Compile Neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo

# Build DEB-package and install it. This should help ensuring the clean removal of installed files.
cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb

# Verify the installation
nvim --version

# Clean up the cloned folder
cd ../..
rm -rf neovim
