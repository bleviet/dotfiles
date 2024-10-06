#!/bin/bash

# Function to display help message
function show_help {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d, --debian      Build the Debian Docker image."
  echo "  -u, --ubuntu      Build the Ubuntu Docker image."
  echo "  -a, --all         Build both Docker images."
  echo "  -h, --help        Display this help message."
  exit 0
}

# Check for command-line arguments
if [[ $# -eq 0 ]]; then
  echo "No options provided. Use -h or --help for usage information."
  exit 1
fi

# Parse command-line arguments
for arg in "$@"; do
  case $arg in
  -d | --debian)
    echo "Building Debian Docker image..."
    docker build -t test-debian -f tests/debian/Dockerfile .
    shift # Remove the argument
    ;;
  -u | --ubuntu)
    echo "Building Ubuntu Docker image..."
    docker build -t test-ubuntu -f tests/ubuntu/Dockerfile .
    shift # Remove the argument
    ;;
  -a | --all)
    echo "Building both Docker images..."
    docker build -t test-debian -f tests/debian/Dockerfile .
    docker build -t test-ubuntu -f tests/ubuntu/Dockerfile .
    shift # Remove the argument
    ;;
  -h | --help)
    show_help
    ;;
  *)
    echo "Unknown option: $arg. Use -h or --help for usage information."
    exit 1
    ;;
  esac
done

echo "Done!"
