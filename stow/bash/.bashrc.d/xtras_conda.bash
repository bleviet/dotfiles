# Define the Miniconda installation path
MINICONDA_PATH="$HOME/miniconda3"

# Function to install Miniconda if it's not installed
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

# Check if Miniconda is installed by looking for the directory and conda command
if ! command -v conda >/dev/null 2>&1; then
  echo "Miniconda is not installed, attempting to install..."
  install_miniconda
fi

# Initialize Miniconda only if it is installed successfully or was already installed
if command -v conda >/dev/null 2>&1; then
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  __conda_setup="$('$MINICONDA_PATH/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
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
