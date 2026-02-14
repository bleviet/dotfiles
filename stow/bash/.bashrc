###############################################################################
# Homebrew environment
###############################################################################
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

###############################################################################
# Load per-shell snippets
# - Sources any *.bash files from ~/.bashrc.d
###############################################################################
# Source all scripts in ~/.bashrc.d directory
if [ -d "$HOME/.bashrc.d" ]; then
  for file in "$HOME/.bashrc.d"/*.bash; do
    [ -r "$file" ] && source "$file"
  done
fi

###############################################################################
# Common shell configuration
# - Loads shared shell helpers and aliases from ~/.config/shell
###############################################################################
if [ -d "$HOME/.config/shell" ]; then
  for file in "$HOME/.config/shell"/*.sh; do
    [ -r "$file" ] && source "$file"
  done
fi

###############################################################################
# Prompt / Prompt extensions
###############################################################################
eval "$(starship init bash)"

###############################################################################
# FZF initialization (if installed)
###############################################################################
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

###############################################################################
# zoxide (if installed)
###############################################################################
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi