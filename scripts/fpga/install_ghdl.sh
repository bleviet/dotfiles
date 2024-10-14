#!/bin/bash

# Update apt cache
sudo apt update

# Install dependencies for GHDL and LLVM
sudo apt install -y gnat zlib1g-dev llvm clang libstdc++-12-dev

# Ensure /tmp/ghdl does not exist, if yes remove it
if [ -d /tmp/ghdl ]; then
  sudo rm -rf /tmp/ghdl
fi

# Clone GHDL repository
git clone https://github.com/ghdl/ghdl.git /tmp/ghdl

# Compile GHDL with LLVM support
cd /tmp/ghdl
./configure --prefix=/usr/local --with-llvm-config=llvm-config
make
sudo make install

# Clean up
sudo rm -rf /tmp/ghdl

echo "GHDL with LLVM support installation complete!"
