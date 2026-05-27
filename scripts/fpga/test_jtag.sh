#!/bin/bash
# scripts/fpga/test_jtag.sh
# Purpose: Diagnose USB and JTAG cable connectivity, rules, and host permissions for FPGA programmers.

set -euo pipefail

echo "========================================="
echo "       JTAG Hardware Diagnostics         "
echo "========================================="

# 1. Check if lsusb is available
if ! command -v lsusb >/dev/null 2>&1; then
  echo "Error: 'lsusb' is not installed. Install 'usbutils' to inspect USB buses."
  exit 1
fi

# 2. Check for typical Xilinx & Digilent vendor IDs
echo "Scanning USB controllers for programmers..."
USB_FOUND=0

# Xilinx Vendor ID: 03fd
# Digilent/FTDI Vendor ID: 0403 (widely used in development boards)
if lsusb | grep -qi "03fd"; then
  echo "✅ Found Xilinx USB JTAG Programmer / Cable!"
  lsusb | grep -i "03fd"
  USB_FOUND=1
fi

if lsusb | grep -qi "0403"; then
  echo "✅ Found Digilent / FTDI JTAG Device (FT2232 / FT232R)!"
  lsusb | grep -i "0403"
  USB_FOUND=1
fi

if [ "$USB_FOUND" -eq 0 ]; then
  echo "⚠️ No Xilinx (03fd) or Digilent (0403) JTAG USB devices detected in 'lsusb'."
  echo "Please check your cable connections and ensure your FPGA board is powered ON."
fi

# 3. Check for Udev Rules
echo ""
echo "Checking udev rules for FPGA programmers..."
UDEV_FOUND=0
RULES_FILES=(
  "/etc/udev/rules.d/52-xilinx-pcusb.rules"
  "/etc/udev/rules.d/52-xilinx-digilent-usb.rules"
)

for file in "${RULES_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "✅ Found udev rules file: $file"
    UDEV_FOUND=1
  fi
done

if [ "$UDEV_FOUND" -eq 0 ]; then
  echo "⚠️ Warning: No standard Xilinx or Digilent udev rule files were found under /etc/udev/rules.d/."
  echo "If JTAG programming fails, you may need to install the cable drivers from Vivado."
  echo "E.g., run: sudo /opt/fpga-tools/Vivado/<version>/data/xicom/cable_drivers/lin64/install_script/install_drivers/install_drivers"
fi

# 4. Check device node permissions
echo ""
echo "Checking permissions on USB device nodes..."
# Inspect /dev/bus/usb permissions
if [ -d "/dev/bus/usb" ]; then
  echo "Permissions for /dev/bus/usb:"
  ls -ld /dev/bus/usb
  echo "If devices are owned strictly by root:root without 666 permissions, non-root users and docker containers cannot utilize them."
  echo "Adding a udev rule or running the container with JTAG mapping is required."
else
  echo "❌ Error: /dev/bus/usb does not exist. Is USB support enabled in your environment?"
fi

echo ""
echo "Diagnostics finished."
echo "========================================="
