#!/bin/bash

# Update system package lists
echo "Updating system package lists..."
sudo apt update -y

# Install dependencies required for Homebrew
echo "Installing required dependencies..."
sudo apt install -y build-essential curl file git

# Check if Homebrew is already installed
if command -v brew >/dev/null 2>&1; then
  echo "Homebrew is already installed."
else
  # Install Homebrew
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apply the changes to the current session
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

  echo "Homebrew installation complete!"
fi

# Verify the installation
echo "Verifying Homebrew installation..."
brew --version

echo "Homebrew is ready to use!"
