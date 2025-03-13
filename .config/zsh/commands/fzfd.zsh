# Allows to select a child (or grandchild, etc) directory of the current directory using fzf
# Usage: fzfd [path]
fzfd() {
  local local_path="${1:-$(pwd)}"
  find "$local_path" -type d 2>/dev/null | fzf
}