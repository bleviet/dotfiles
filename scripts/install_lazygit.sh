#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y curl

# Get the latest LazyGit version
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

# Download the latest LazyGit release
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

# Extract the downloaded tarball
tar xf lazygit.tar.gz lazygit

# Move LazyGit binary to /usr/local/bin
sudo install lazygit /usr/local/bin

# Clean up
rm lazygit.tar.gz lazygit

# Verify the installation
lazygit --version
