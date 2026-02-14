###############################################################################
# functions.sh
# Purpose: small, portable shell helper functions used across configurations
###############################################################################

###############################################################################
# Git helpers
###############################################################################
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/* //'
}

gkf() {
  local file
  file=$(fzf)
  if [[ -n "$file" ]]; then
    gitk "$file"
  fi
}

###############################################################################
# Navigation helpers
###############################################################################
cdf() {
  local file
  file=$(fzf)
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

###############################################################################
# Yank helper (yazi wrapper)
###############################################################################
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}