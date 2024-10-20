eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Source all scripts in ~/.bashrc.d directory
if [ -d "$HOME/.bashrc.d" ]; then
  for file in "$HOME/.bashrc.d"/*.bash; do
    [ -r "$file" ] && source "$file"
  done
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
