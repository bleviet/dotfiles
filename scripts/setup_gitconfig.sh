#!/bin/bash
# scripts/setup_gitconfig.sh
# Purpose: create a simple ~/.gitconfig using environment vars or prompts without hanging

set -euo pipefail

# Use environment variables or prompt for user information (avoid hanging if non-interactive)
if [ -z "${GIT_USER_NAME:-}" ]; then
  if [ -t 0 ]; then
    read -p "Enter your name for Git configuration: " GIT_USER_NAME
  else
    GIT_USER_NAME="Default User"
  fi
fi

if [ -z "${GIT_USER_EMAIL:-}" ]; then
  if [ -t 0 ]; then
    read -p "Enter your email for Git configuration: " GIT_USER_EMAIL
  else
    GIT_USER_EMAIL="user@example.com"
  fi
fi

###############################################################################
# Create the .gitconfig file
###############################################################################
cat <<EOL >~/.gitconfig
[user]
    name = $GIT_USER_NAME
    email = $GIT_USER_EMAIL

[core]
    editor = nvim
    autocrlf = input

[url "https://github.com/"]
    insteadOf = gh:
EOL

echo ".gitconfig has been set up with name: $GIT_USER_NAME, email: $GIT_USER_EMAIL."
