#!/bin/bash

# Function to update system package lists
update_system() {
  echo "Updating system package lists..."
  if ! sudo apt update -y; then
    echo "Error: Failed to update system packages."
    return 1
  fi
}

# Function to install required dependencies
install_dependencies() {
  echo "Installing required dependencies..."
  if ! sudo apt install -y build-essential curl file git; then
    echo "Error: Failed to install dependencies."
    return 1
  fi
}

# Function to check if Homebrew is installed
is_brew_installed() {
  command -v brew >/dev/null 2>&1
}

# Function to install Homebrew
install_brew() {
  echo "Installing Homebrew..."
  if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    # Apply the changes to the current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "Homebrew installation complete!"
    return 0
  else
    echo "Error: Failed to install Homebrew."
    return 1
  fi
}

# Function to verify Homebrew installation
verify_brew() {
  echo "Verifying Homebrew installation..."
  if brew --version; then
    echo "Homebrew is ready to use!"
  else
    echo "Error: Homebrew verification failed."
    return 1
  fi
}

# Main installation logic
update_system || exit 1
install_dependencies || exit 1

if is_brew_installed; then
  echo "Homebrew is already installed."
else
  if install_brew; then
    verify_brew
  fi
fi
