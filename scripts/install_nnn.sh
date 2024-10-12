#!/bin/bash

# Step 1: Install dependencies
sudo apt-get update
sudo apt-get install -y git make gcc pkg-config libncursesw5-dev libreadline-dev

# Step 2: Clone the repository
git clone https://github.com/jarun/nnn.git

# Step 3: Build the project
cd nnn
make

# Step 4: Install the binary
sudo make install

# Step 5: Clean up
cd ..
rm -rf nnn

echo "nnn has been successfully installed."

# Step 6: Install nnn plugins
sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
