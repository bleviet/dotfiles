#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Install Starship prompt
# The minimal, blazing-fast, and infinitely customizable prompt
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Define the init script line
INIT_SCRIPT='eval "$(starship init bash)"'

# Check if the init script line is already in .bashrc
if ! grep -Fxq "$INIT_SCRIPT" ~/.bashrc; then
  # If not, append the init script line to .bashrc
  echo "$INIT_SCRIPT" >>~/.bashrc
  echo "Starship init script added to .bashrc"
else
  echo "Starship init script already present in .bashrc"
fi
