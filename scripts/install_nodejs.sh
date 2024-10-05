#!/bin/bash

# Ensure the script exits if any command fails
set -e

# Download and run the NodeSource setup script for the LTS version of Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

# Install Node.js
sudo apt-get install -y nodejs

# Verify the installation
node -v
npm -v
