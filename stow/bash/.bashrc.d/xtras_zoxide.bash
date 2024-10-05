# Function to install zoxide if it's not installed
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

# Check if zoxide is installed
if ! command -v zoxide >/dev/null 2>&1; then
  echo "zoxide is not installed, attempting to install..."
  install_zoxide
fi

# Initialize zoxide only if it is installed successfully or was already installed
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
