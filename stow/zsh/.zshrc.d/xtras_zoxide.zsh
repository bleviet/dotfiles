# Function to check if zoxide is installed
is_zoxide_installed() {
  command -v zoxide >/dev/null 2>&1
}

# Function to install zoxide
install_zoxide() {
  echo "Installing zoxide..."

  # Download and run the zoxide installer
  if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
    echo "zoxide successfully installed."
    return 0
  else
    echo "Error: Failed to install zoxide. Please check your internet connection or install it manually."
    return 1
  fi
}

# Function to initialize zoxide
initialize_zoxide() {
  if is_zoxide_installed; then
    eval "$(zoxide init zsh)"
  fi
}

# Main setup logic
if ! is_zoxide_installed; then
  echo "zoxide is not installed, attempting to install..."
  if install_zoxide; then
    initialize_zoxide
  fi
else
  initialize_zoxide
fi
