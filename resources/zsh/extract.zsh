extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file> [output_directory]"
    return 1
  fi

  if [ -n "${2:-}" ]; then
    ouch decompress "$1" --dir "$2"
  else
    ouch decompress "$1"
  fi
}