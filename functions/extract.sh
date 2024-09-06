extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file> [output_directory]"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi

  local file="$1"
  local output_dir="${2:-.}"

  # Create the output directory if it doesn't exist
  mkdir -p "$output_dir"

  case "$file" in
    *.tar.bz2)   
      tar xvjf "$file" -C "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.tar.gz)    
      tar xvzf "$file" -C "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.bz2)       
      bunzip2 -c "$file" > "$output_dir/$(basename "${file%.bz2}")" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.rar)       
      unrar x "$file" "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.gz)        
      gunzip -c "$file" > "$output_dir/$(basename "${file%.gz}")" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.tar)       
      tar xvf "$file" -C "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.tbz2)      
      tar xvjf "$file" -C "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.tgz)       
      tar xvzf "$file" -C "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.zip)       
      unzip "$file" -d "$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.Z)         
      uncompress -c "$file" > "$output_dir/$(basename "${file%.Z}")" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *.7z)        
      7z x "$file" -o"$output_dir" || { echo "Error extracting '$file'"; return 1; }
      ;;
    *)           
      echo "Error: '$file' cannot be extracted via extract"
      return 1
      ;;
  esac
}