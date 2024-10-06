#!/bin/bash

# Use environment variables or prompt for user information
user_name=${GIT_USER_NAME:-$(read -p "Enter your name: " temp && echo "$temp")}
user_email=${GIT_USER_EMAIL:-$(read -p "Enter your email: " temp && echo "$temp")}

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
