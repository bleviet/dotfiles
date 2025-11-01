#!/bin/bash

# Function to check if Oh My Zsh is installed
is_ohmyzsh_installed() {
  [ -d "$HOME/.oh-my-zsh" ]
}

# Function to install Oh My Zsh
install_ohmyzsh() {
  echo "Installing Oh My Zsh..."

  # Run the Oh My Zsh installer script non-interactively
  if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    echo "Oh My Zsh successfully installed."
    return 0
  else
    echo "Error: Failed to install Oh My Zsh. Please check your internet connection or install it manually."
    return 1
  fi
}

# Main setup logic
if ! is_ohmyzsh_installed; then
  install_ohmyzsh
else
  echo "Oh My Zsh is already installed."
fi
