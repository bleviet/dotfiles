# Define the Miniconda installation path
MINICONDA_PATH="$HOME/miniconda3"

# Function to check if conda is installed
is_conda_installed() {
  command -v conda >/dev/null 2>&1
}

# Function to install Miniconda
install_miniconda() {
  echo "Installing Miniconda..."

  # Create the Miniconda directory and download the installer
  mkdir -p "$MINICONDA_PATH"
  if wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O "$MINICONDA_PATH/miniconda.sh"; then
    # Run the installer
    if bash "$MINICONDA_PATH/miniconda.sh" -b -u -p "$MINICONDA_PATH"; then
      echo "Miniconda successfully installed."
      # Remove the installer file after successful installation
      rm "$MINICONDA_PATH/miniconda.sh"
      return 0
    else
      echo "Error: Miniconda installation failed."
      return 1
    fi
  else
    echo "Error: Failed to download Miniconda installer. Please check your internet connection."
    return 1
  fi
}

# Function to initialize Miniconda
initialize_conda() {
  if is_conda_installed; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('$MINICONDA_PATH/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [ $? -eq 0 ]; then
      eval "$__conda_setup"
    else
      if [ -f "$MINICONDA_PATH/etc/profile.d/conda.sh" ]; then
        . "$MINICONDA_PATH/etc/profile.d/conda.sh"
      else
        export PATH="$MINICONDA_PATH/bin:$PATH"
      fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
  else
    echo "Warning: Miniconda is not available."
  fi
}

# Main setup logic
if ! is_conda_installed; then
  echo "Miniconda is not installed, attempting to install..."
  if install_miniconda; then
    initialize_conda
  fi
else
  initialize_conda
fi
