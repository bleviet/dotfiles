# Function to start the SSH agent and add keys
function start_ssh_agent {
  if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
  fi
  ssh-add -l &>/dev/null
  if [ $? -ne 0 ]; then
    ssh-add ~/.ssh/id_rsa # Adjust the path to your private key if necessary
  fi
}

# Call the function to start the SSH agent and add keys
start_ssh_agent
