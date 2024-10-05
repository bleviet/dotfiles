# Git branch in prompt
parse_git_branch() {
  git branch 2>/dev/null | grep '\*' | sed 's/* //'
}
