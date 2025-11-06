# Git branch in prompt
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/* //'
}

# View gitk for a file selected with fzf
gkf() {
  local file
  # Run fzf and store the selected file path in the 'file' variable
  file=$(fzf)

  # Only run gitk if a file was actually selected (i.e., you didn't press Esc)
  if [[ -n "$file" ]]; then
      gitk "$file"
  fi
}

# cdf: Change directory to the directory containing the file selected by fzf.
cdf() {
  local file
  file=$(fzf)
  if [[ -n "$file" ]]; then
    cd "$(dirname "$file")"
  fi
}

y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}