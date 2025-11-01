eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Source all scripts in ~/.bashrc.d directory
if [ -d "$HOME/.bashrc.d" ]; then
  for file in "$HOME/.bashrc.d"/*.bash; do
    [ -r "$file" ] && source "$file"
  done
fi

# Source common shell configuration
if [ -d "$HOME/.config/shell" ]; then
  for file in "$HOME/.config/shell"/*.sh; do
    [ -r "$file" ] && source "$file"
  done
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(starship init bash)"
