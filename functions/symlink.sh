symlink() {
  # Check if the correct number of arguments is provided
  if [ "$#" -ne 2 ]; then
    echo "Usage: symlink <source_directory> <target_directory>"
    return 1
  fi

  # Define source and target directories from arguments
  SOURCE_DIR="$1"
  TARGET_DIR="$2"
  GITIGNORE_FILE="$SOURCE_DIR/.gitignore"

  # Read .gitignore patterns
  IGNORE_PATTERNS=()
  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    IGNORE_PATTERNS+=("$line")
  done < "$GITIGNORE_FILE"

  # Function to check if a file matches any .gitignore pattern
  is_ignored() {
    local file="$1"
    for pattern in "${IGNORE_PATTERNS[@]}"; do
      if [[ "$file" == $SOURCE_DIR/$pattern || "$file" == $SOURCE_DIR/$pattern/* ]]; then
        return 0
      fi
    done
    return 1
  }

  # Create symlinks for directories
  find "$SOURCE_DIR" -type d | while read -r dir; do
    # Check if the directory is ignored
    if ! is_ignored "$dir"; then
      # Get the relative path of the directory
      relative_path="${dir#$SOURCE_DIR/}"
      
      # Create the symlink for the directory
      ln -s "$dir" "$TARGET_DIR/$relative_path"
    fi
  done

  # Find and symlink files that are not ignored
  find "$SOURCE_DIR" -type f | while read -r file; do
    # Check if the file is ignored
    if ! is_ignored "$file"; then
      # Get the relative path of the file
      relative_path="${file#$SOURCE_DIR/}"
      
      # Create the target directory structure if it doesn't exist
      mkdir -p "$TARGET_DIR/$(dirname "$relative_path")"
      
      # Create the symlink for the file
      ln -s "$file" "$TARGET_DIR/$relative_path"
    fi
  done
}