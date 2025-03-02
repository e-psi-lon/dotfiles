# Allows to select a child (or grandchild, etc) directory of the current directory using fzf
# Usage: fzfd [path]
fzfd() {
  local path="${1:-$(pwd)}"
  find "$path" -type d 2>/dev/null | fzf
}