# Function to check if fzf is installed
is_fzf_installed() {
  command -v fzf >/dev/null 2>&1
}

# Function to install fzf
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

# Function to initialize fzf
initialize_fzf() {
  if is_fzf_installed; then
    eval "$(fzf --bash)"
  fi
}

# Main setup logic
if ! is_fzf_installed; then
  echo "fzf is not installed, attempting to install..."
  if install_fzf; then
    initialize_fzf
  fi
else
  initialize_fzf
fi
