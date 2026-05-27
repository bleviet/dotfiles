#!/bin/bash
# scripts/fpga/launch_vivado.sh
# Purpose: Start a Vivado Docker container with full GUI (X11) forwarding, JTAG USB forwarding, and local volume mounting.

set -euo pipefail

IMAGE_TAG="vivado-ubuntu24"
HOST_TOOLS_DIR="/opt/fpga-tools"
HOST_PROJECTS_DIR="$HOME/projects"

echo "========================================="
echo "       Vivado Container Launcher         "
echo "========================================="

# 1. Ensure projects directory exists
mkdir -p "$HOST_PROJECTS_DIR"

# 2. Check X11 forwarding settings
if [ -z "${DISPLAY:-}" ]; then
  echo "Error: DISPLAY environment variable is not set. GUI application will fail."
  exit 1
fi

echo "Configuring X11 authorization..."
# Enable local connections to X server from containers
if command -v xhost >/dev/null 2>&1; then
  xhost +local:docker >/dev/null || xhost + >/dev/null || echo "Warning: xhost config skipped."
fi

# 3. Check for JTAG USB Devices
echo "Scanning for JTAG / USB devices..."
JTAG_OPTS=""
if [ -d "/dev/bus/usb" ]; then
  echo "Found USB bus at /dev/bus/usb. Forwarding USB controllers..."
  # Mount USB bus and use privileged mode to let JTAG programmers dynamically mount devices
  JTAG_OPTS="--privileged -v /dev/bus/usb:/dev/bus/usb"
else
  echo "Warning: /dev/bus/usb not found. JTAG programmers may not be available inside the container."
fi

# 4. Check if Docker image is built
if ! docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
  echo "Docker image '$IMAGE_TAG' not found. Building it now..."
  
  # Determine local UID and GID to avoid permission conflicts
  USER_ID=$(id -u)
  GROUP_ID=$(id -g)
  
  # Run docker build from repository root
  ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
  docker build \
    --build-arg USER_ID="$USER_ID" \
    --build-arg GROUP_ID="$GROUP_ID" \
    -t "$IMAGE_TAG" \
    -f "$ROOT_DIR/scripts/fpga/Dockerfile.vivado" \
    "$ROOT_DIR"
fi

# 5. Launch the Container
echo "Starting container..."
echo "Mounting Host Tools: $HOST_TOOLS_DIR -> /opt/fpga-tools"
echo "Mounting Host Projects: $HOST_PROJECTS_DIR -> /home/developer/projects"

# Run with interactive terminal, X11 variables, JTAG configs, and tool mounts
docker run -it --rm \
  --name "vivado-run-$(date +%s)" \
  -e DISPLAY="$DISPLAY" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -e XAUTHORITY="${XAUTHORITY:-}" \
  -v "${XAUTHORITY:-/dev/null}:${XAUTHORITY:-/dev/null}:ro" \
  -v "$HOST_TOOLS_DIR:/opt/fpga-tools" \
  -v "$HOST_PROJECTS_DIR:/home/developer/projects" \
  $JTAG_OPTS \
  --net=host \
  "$IMAGE_TAG" \
  "${@:-/bin/bash}" # Run bash by default, or execute arguments (e.g. ./launch_vivado.sh vivado)
