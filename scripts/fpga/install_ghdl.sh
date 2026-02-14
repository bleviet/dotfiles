#!/bin/bash

set -euo pipefail

###############################################################################
# scripts/fpga/install_ghdl.sh
# Purpose: build and install GHDL with LLVM support
###############################################################################

###############################################################################
# Prep
###############################################################################
sudo apt update

###############################################################################
# Dependencies
###############################################################################
sudo apt install -y gnat zlib1g-dev llvm clang libstdc++-12-dev

###############################################################################
# Build and install
###############################################################################
if [ -d /tmp/ghdl ]; then
  sudo rm -rf /tmp/ghdl
fi

git clone https://github.com/ghdl/ghdl.git /tmp/ghdl
cd /tmp/ghdl
./configure --prefix=/usr/local --with-llvm-config=llvm-config
make
sudo make install

sudo rm -rf /tmp/ghdl

echo "GHDL with LLVM support installation complete!"
