# ENVRC_FILE represents the path to the ready to use .envrc file in the nix store
# FLAKE_DIR represents the path to directory containing all available flakes in the nix store

# usage setup-dev <language> [<template:value>...]

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <language> [<template:value>...]"
  exit 1
fi

if [ -z "$ENVRC_FILE" ] || [ -z "$FLAKE_DIR" ]; then
  echo "Error: ENVRC_FILE and FLAKE_DIR environment variables must be set."
  exit 1
fi

LANGUAGE="$1"
shift

declare -A VARS
for arg in "$@"; do
  key="${arg%%:*}"
  value="${arg#*:}"
  VARS[$key]="$value"
done

# Set defaults
: "${VARS[NIXPKGS_VERSION]:='25.11'}"

verify_required_vars() {
  local required_vars=("$@")
  for var in "${required_vars[@]}"; do
    if [ -z "${VARS[$var]}" ]; then
      echo "Error: Missing required variable '$var' for language '$LANGUAGE'."
      exit 1
    fi
  done
}

escape_sed() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//|/\\|}"
  value="${value//&/\\&}"
  echo "$value"
}

apply_template() {
  local flake_file="$1"
  local temp_flake
  temp_flake=$(mktemp)
  trap 'rm -f "$temp_flake"' EXIT
  cp "$flake_file" "$temp_flake"
  for key in "${!VARS[@]}"; do
    escaped=$(escape_sed "${VARS[$key]}")
    sed -i "s|{{${key}}}|${escaped}|g" "$temp_flake"
  done
  mv "$temp_flake" "./flake.nix"
}


# Decode the language and map it to the corresponding flake
case "$LANGUAGE" in
  "jvm")
    verify_required_vars "JVM_PACKAGE"
    apply_template "$FLAKE_DIR/jvm.nix"
    ;;
  "c")
    apply_template "$FLAKE_DIR/c.nix"
    ;;
  *)
    echo "Error: Unsupported language '$LANGUAGE'. Supported languages are: jvm, c."
    exit 1
    ;;
esac

# Copy the template .envrc file to the current directory
cp "$ENVRC_FILE" "./.envrc"

echo "Setup completed for language '$LANGUAGE'."