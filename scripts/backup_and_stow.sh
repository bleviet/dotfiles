#!/bin/bash
# scripts/backup_and_stow.sh
# Purpose: deploy dotfiles using GNU Stow (core, OS, and host-specific)

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

# Detect OS and Hostname
OS_ID="unknown"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
elif [ "$(uname)" = "Darwin" ]; then
  OS_ID="macos"
fi
MY_HOSTNAME="$(hostname)"

echo "========================================="
if [[ $DRY_RUN -eq 1 ]]; then
  echo "   Stow Configuration Deployment (DRY RUN)"
else
  echo "   Stow Configuration Deployment"
fi
echo "========================================="
echo "Detected OS: $OS_ID"
echo "Hostname: $MY_HOSTNAME"

###############################################################################
# Helpers
###############################################################################

# stow --adopt cannot move a dangling symlink; clear them first.
remove_dangling_symlinks() {
  local stow_dir="$1" pkg="$2"
  local pkg_dir="$stow_dir/$pkg"
  [ -d "$pkg_dir" ] || return 0
  while IFS= read -r src; do
    local rel="${src#"$pkg_dir"/}"
    local target="$HOME/$rel"
    if [ -L "$target" ] && [ ! -e "$target" ]; then
      echo "Removing dangling symlink: $target"
      rm -f "$target"
    fi
  done < <(find "$pkg_dir" -mindepth 1)
}

stow_packages() {
  local dir="$1"; shift
  local packages=("$@")
  local stow_flags=(--adopt --no-folding)

  if [[ $DRY_RUN -eq 1 ]]; then
    stow_flags=(--simulate --verbose --adopt --no-folding)
  else
    for pkg in "${packages[@]}"; do
      remove_dangling_symlinks "$dir" "$pkg"
    done
  fi

  echo "Stowing packages [${packages[*]}] from $dir..."
  # --adopt moves conflicting real files into the stow source then symlinks them;
  # the git restore below immediately restores our tracked versions.
  if stow "${stow_flags[@]}" -d "$dir" -t "$HOME" "${packages[@]}"; then
    echo "Stowed successfully."
  else
    echo "Warning: Stow returned an error for folder $dir."
  fi
}

###############################################################################
# Stow deploy
###############################################################################
# 1. Stow Core packages
stow_packages "$ROOT_DIR/core" bash zsh common nvim tmux

# 2. Stow OS-specific packages
if [ -d "$ROOT_DIR/os/$OS_ID" ]; then
  echo "OS-specific configuration folder found for '$OS_ID'."
  stow_packages "$ROOT_DIR/os/$OS_ID" common
else
  echo "No OS-specific folder found for '$OS_ID'. Skipping."
fi

# 3. Stow Host-specific packages
if [ -d "$ROOT_DIR/host/$MY_HOSTNAME" ]; then
  echo "Host-specific configuration folder found for '$MY_HOSTNAME'."
  stow_packages "$ROOT_DIR/host/$MY_HOSTNAME" common
else
  echo "No host-specific folder found for exact hostname '$MY_HOSTNAME'."
fi

###############################################################################
# Restore tracked versions if --adopt overwrote any stow source files
###############################################################################
if [[ $DRY_RUN -eq 0 ]] && ! git -C "$ROOT_DIR" diff --quiet; then
  echo "Restoring tracked dotfile content (overwriting files adopted from system)..."
  git -C "$ROOT_DIR" restore .
fi

echo "Stow deployment finished."
