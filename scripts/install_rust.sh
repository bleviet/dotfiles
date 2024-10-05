#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install rustup (the Rust toolchain installer)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source the cargo environment (assuming default installation path)
source $HOME/.cargo/env

# Update rustup to the latest version
rustup self update

# Update Rust to the latest stable version
rustup update stable

# Verify the Rust version
rustc --version
