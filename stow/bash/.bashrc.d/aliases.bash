# LS
alias ls='ls --color=auto'
alias l='ls -lh'
alias ll='ls -laF'

# Navigation
# Alias to navigate up one directory like in Zsh
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# GIT
alias gs='git status'
alias gso='git status -uno'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gk='gitk'
alias gka='gitk --all'
alias gg='lazygit'

# MISCELLANEOUS
alias c='clear'
alias src='source ~/.bashrc'
alias n='nnn -de'

# FZF
alias f='fzf | tee >(xclip -sel clip)'
alias fp="fzf --preview 'batcat --style=numbers --color=always {}' | tee >(xclip -sel clip)"
alias fe='$EDITOR $(fzf)'
