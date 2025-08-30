#!/bin/bash
#
# This script is executed inside the 'fpga-dev' Distrobox container.
# It installs GHDL and provides instructions for other FPGA tools.
#

set -e

echo "--- Installing GHDL and its dependencies ---"
sudo apt-get update
sudo apt-get install -y gnat zlib1g-dev llvm clang libstdc++-12-dev git make

echo "--- Cloning and building GHDL from source ---"
if [ -d /tmp/ghdl ]; then
  sudo rm -rf /tmp/ghdl
fi
git clone https://github.com/ghdl/ghdl.git /tmp/ghdl
cd /tmp/ghdl
./configure --prefix=/usr/local --with-llvm-config=llvm-config
make
sudo make install
sudo rm -rf /tmp/ghdl
echo "--- GHDL installation complete ---"


echo "--- Creating README for proprietary FPGA tools ---"
cat << 'EOF' > ~/README_FPGA_TOOLS.md
# FPGA Development Environment Setup

This environment is set up for FPGA development. GHDL (a VHDL simulator) has been pre-installed.

For proprietary tools like Xilinx Vivado and Intel Quartus, you need to perform a manual installation due to their size and licensing requirements.

## Installing Xilinx Vivado

Vivado is a large suite and requires a Xilinx account for download.

1.  **Download:** Go to the [Xilinx Unified Installer page](https://www.xilinx.com/support/download.html) to download the installer. You will need to log in.
2.  **Installation:** Run the installer script. It has a graphical interface.
    *   You can find detailed guides here:
        *   [Digilent Guide](https://digilent.com/reference/programmable-logic/guides/xilinx-unified-installer)
        *   [Hackster.io Guide for Ubuntu](https://www.hackster.io/whitney-knitter/vivado-vitis-petalinux-2024-2-install-on-ubuntu-59f3c3)

## Installing Intel Quartus Prime

Quartus also requires an Intel account and has a large download size.

1.  **Download:** Download the Quartus Prime Lite Edition from the [Intel FPGA software download page](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html). You will need an account.
2.  **Dependencies:** Quartus often requires 32-bit compatibility libraries. You may need to install them first:
    \`\`\`bash
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386
    \`\`\`
3.  **Installation:** Run the `setup.sh` script from the downloaded Quartus archive.
    *   You can find detailed guides here:
        *   [University of Florida Guide (PDF)](https://mil.ufl.edu/3701/docs/quartus/Quartus19.1_install_on_Linux.pdf)
        *   [GitHub guide with dependency details](https://github.com/Jefferson-Lopes/quartus-installation)

These tools should be installed in your home directory within this container.
EOF

echo "--- README_FPGA_TOOLS.md created in your home directory ---"

# Create a marker file to indicate that the setup is complete.
touch ~/.fpga_setup_done

echo "--- FPGA environment setup is complete! ---"
