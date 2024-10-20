# Function to install fzf if it's not installed
install_fzf() {
  echo "Installing fzf..."

  # Clone the fzf repository and run the install script
  if git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --bin; then
    echo "fzf successfully installed."
    return 0
  else
    echo "Error: Failed to install fzf. Please check your internet connection or install it manually."
    return 1
  fi
}

# Check if fzf is installed by looking for its executable
if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is not installed, attempting to install..."
  install_fzf
fi

# Initialize fzf only if it is installed successfully or was already installed
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
