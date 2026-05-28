#!/bin/bash
# scripts/install_dependencies.sh
# Purpose: install system packages declared in packages/manifest.toml

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$ROOT_DIR/packages/install.py" --group system "$@"
