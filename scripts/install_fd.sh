#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential cargo

# Clone the fd repository
git clone https://github.com/sharkdp/fd.git
cd fd

# Build and install fd
cargo install --path .

# Verify installation
fd --version

# Clean up
cd ..
rm -rf fd
