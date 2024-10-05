#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential cargo

# Clone the ripgrep repository
git clone https://github.com/BurntSushi/ripgrep.git
cd ripgrep

# Build and install ripgrep
cargo install --path .

# Verify installation
rg --version

# Clean up
cd ..
rm -rf ripgrep
