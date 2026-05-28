#!/bin/bash
# scripts/lib.sh
# Shared utilities — source this file; do not execute it directly.

detect_os() {
  if [ -f /etc/os-release ]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "$ID"
  elif [ "$(uname)" = "Darwin" ]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

run_as_root() {
  if [ "$EUID" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      sudo "$@"
    else
      echo "Error: root privileges required but sudo is not available." >&2
      exit 1
    fi
  else
    "$@"
  fi
}
