#!/bin/bash
# build_test_containers.sh
# Purpose: Build and test Docker images for the supported matrix (Debian, Ubuntu, Rocky Linux)

set -euo pipefail

echo "========================================="
echo "   Dotfiles Container Testing Matrix    "
echo "========================================="

# Helper to print usage
show_help() {
  echo "Usage: $0 [options]"
  echo "Options:"
  echo "  -d,   --debian      Build & smoke test Debian Stable"
  echo "  -u20, --ubuntu20    Build & smoke test Ubuntu 20.04"
  echo "  -u22, --ubuntu22    Build & smoke test Ubuntu 22.04"
  echo "  -r8,  --rocky8      Build & smoke test Rocky Linux 8"
  echo "  -r9,  --rocky9      Build & smoke test Rocky Linux 9"
  echo "  -r10, --rocky10     Build & smoke test Rocky Linux 10"
  echo "  -a,   --all         Build & smoke test the entire matrix"
  echo "  -h,   --help        Display this help message"
  exit 0
}

# Run smoke test on a completed container
run_smoke_test() {
  local image_tag="$1"
  local distro_name="$2"
  echo "-----------------------------------------"
  echo "Smoke Testing: $distro_name ($image_tag)"
  echo "-----------------------------------------"

  # Verify git is configured
  docker run --rm "$image_tag" git config --global user.name | grep -q "Test User" || {
    echo "❌ Fail: Git user.name not configured correctly!"
    return 1
  }

  # Verify stow symlinks exist
  docker run --rm "$image_tag" ls -la /home/user/ | grep -q "\.bashrc ->" || {
    echo "❌ Fail: Stow did not link .bashrc successfully!"
    return 1
  }

  # Verify local feature flags exist
  docker run --rm "$image_tag" cat /home/user/.dotfiles.local | grep -q "DOTFILES_FEATURE_GUI=" || {
    echo "❌ Fail: .dotfiles.local feature flags not initialized!"
    return 1
  }

  # Verify OS-specific configurations were stowed
  if [[ "$distro_name" == *"Rocky"* ]]; then
    docker run --rm "$image_tag" ls -la /home/user/.config/shell/ | grep -q "os_rocky" || {
      echo "❌ Fail: Rocky OS-specific aliases were not stowed!"
      return 1
    }
  elif [[ "$distro_name" == *"Debian"* ]]; then
    docker run --rm "$image_tag" ls -la /home/user/.config/shell/ | grep -q "os_debian" || {
      echo "❌ Fail: Debian OS-specific aliases were not stowed!"
      return 1
    }
  elif [[ "$distro_name" == *"Ubuntu"* ]]; then
    docker run --rm "$image_tag" ls -la /home/user/.config/shell/ | grep -q "os_ubuntu" || {
      echo "❌ Fail: Ubuntu OS-specific aliases were not stowed!"
      return 1
    }
  fi

  echo "✅ Smoke test PASSED for $distro_name!"
  return 0
}

build_and_test() {
  local base_image="$1"
  local tag="$2"
  local name="$3"

  echo "Building Docker image: $name ($base_image) -> $tag..."
  docker build --build-arg BASE_IMAGE="$base_image" -t "$tag" -f tests/Dockerfile .
  run_smoke_test "$tag" "$name"
}

if [[ $# -eq 0 ]]; then
  echo "Error: No option specified. Use -h or --help for help."
  exit 1
fi

for arg in "$@"; do
  case $arg in
    -d|--debian)
      build_and_test "debian:stable" "test-debian" "Debian Stable"
      ;;
    -u20|--ubuntu20)
      build_and_test "ubuntu:20.04" "test-ubuntu20" "Ubuntu 20.04"
      ;;
    -u22|--ubuntu22)
      build_and_test "ubuntu:22.04" "test-ubuntu22" "Ubuntu 22.04"
      ;;
    -r8|--rocky8)
      build_and_test "rockylinux:8" "test-rocky8" "Rocky Linux 8"
      ;;
    -r9|--rocky9)
      build_and_test "rockylinux:9" "test-rocky9" "Rocky Linux 9"
      ;;
    -r10|--rocky10)
      # Pull from official rockylinux namespace if rockylinux:10 is not available shorthand
      build_and_test "rockylinux/rockylinux:10" "test-rocky10" "Rocky Linux 10"
      ;;
    -a|--all)
      echo "Running full test matrix build..."
      build_and_test "debian:stable" "test-debian" "Debian Stable"
      build_and_test "ubuntu:20.04" "test-ubuntu20" "Ubuntu 20.04"
      build_and_test "ubuntu:22.04" "test-ubuntu22" "Ubuntu 22.04"
      build_and_test "rockylinux:8" "test-rocky8" "Rocky Linux 8"
      build_and_test "rockylinux:9" "test-rocky9" "Rocky Linux 9"
      build_and_test "rockylinux/rockylinux:10" "test-rocky10" "Rocky Linux 10"
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Unknown option: $arg. Use -h or --help for usage."
      exit 1
      ;;
  esac
done

echo "========================================="
echo "   All Matrix Builds & Tests Completed!  "
echo "========================================="
