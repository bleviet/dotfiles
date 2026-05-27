# Ubuntu-specific shell configurations
# Sourced automatically in Ubuntu environments

alias apt-search="apt-cache search"
alias apt-install="sudo apt install"
alias apt-update="sudo apt update && sudo apt upgrade"
alias apt-clean="sudo apt autoremove && sudo apt autoclean"

# Ubuntu-specific snaps
if command -v snap >/dev/null 2>&1; then
  alias snap-list="snap list"
fi
