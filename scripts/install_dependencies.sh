#!/bin/bash

set -euo pipefail

###############################################################################
# scripts/install_dependencies.sh
# Purpose: install minimal packages required by setup and tests
###############################################################################
sudo apt-get update && sudo apt-get install -y \
  bat \
  curl \
  file \
  fontconfig \
  git \
  procps \
  stow \
  unzip \
  p7zip-full \
  wget \
  xclip
