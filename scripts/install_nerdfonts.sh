#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Function to download and install a Nerd Font
install_nerd_font() {
  local font_name="$1"
  local url="$2"
  local temp_dir=$(mktemp -d)

  echo "Installing $font_name Nerd Font..."

  # Download the font archive
  curl -L -o "$temp_dir/$font_name.zip" "$url"

  # Unzip the font archive
  unzip -q "$temp_dir/$font_name.zip" -d "$temp_dir/$font_name"

  # Create fonts directory if it doesn't exist
  mkdir -p ~/.local/share/fonts

  # Move the fonts to the fonts directory
  find "$temp_dir/$font_name" -name "*.ttf" -exec mv {} ~/.local/share/fonts/ \;
  find "$temp_dir/$font_name" -name "*.otf" -exec mv {} ~/.local/share/fonts/ \;

  # Refresh the font cache
  fc-cache -fv

  # Clean up
  rm -rf "$temp_dir"

  echo "$font_name Nerd Font installed successfully!"
}

# URLs for FireCode and Hack Nerd Fonts
FIRECODE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip"
HACK_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip"

# Install the fonts
install_nerd_font "FireCode" "$FIRECODE_URL"
install_nerd_font "Hack" "$HACK_URL"
