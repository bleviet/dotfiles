#!/bin/bash

# Prompt for user information
read -p "Enter your name: " user_name
read -p "Enter your email: " user_email

# Create the .gitconfig file with user-specific information
cat <<EOL >~/.gitconfig
[user]
    name = $user_name
    email = $user_email

[core]
    editor = nvim
    autocrlf = input

[url "https://github.com/"]
    insteadOf = gh:
EOL

echo ".gitconfig has been set up with your information."
