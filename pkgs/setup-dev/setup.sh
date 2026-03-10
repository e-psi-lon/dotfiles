# The following variables are guaranteed to be set at build time:
# ENVRC_FILE represents the path to the ready to use .envrc file in the nix store
# FLAKE_DIR represents the path to directory containing all available flakes in the nix store

# usage setup-dev <language> [--nixpkgs VERSION] [--force] [args...]

PERMISSIONS=644 # rw-r--r-- - Base permissions

# Check a language has been provided
if [ "$#" -lt 1 ]; then
  executable=$(basename "$0")
  echo "Usage: $executable <language> [--nixpkgs VERSION] [--force] [args...]"
  exit 1
fi

LANGUAGE="$1"
shift

# Hold template substitution variables
declare -A VARS
VARS[NIXPKGS_VERSION]='25.11'
FORCE=false

# Parse flags and language-specific arguments
declare -a LANGUAGE_ARGS
while [ "$#" -gt 0 ]; do
  case "$1" in
    --nixpkgs)
      if [ "$#" -lt 2 ]; then
        echo "Error: --nixpkgs requires a version argument (e.g., --nixpkgs 25.11)."
        exit 1
      fi
      VARS[NIXPKGS_VERSION]="$2"
      shift 2
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      LANGUAGE_ARGS+=("$1")
      shift
      ;;
  esac
done

if [ "$FORCE" = true ]; then
  echo "Warning: FORCE flag is set. Existing flake.nix and .envrc files will be overwritten."
fi

# Verify that the current path don't contain a flake.nix 
# nor a .envrc file to avoid overwriting them unless FORCE is set to true
if [ "$FORCE" = false ]; then
  if [ -f "./flake.nix" ] || [ -f "./.envrc" ]; then
    echo "Error: Current directory already contains a flake.nix or .envrc file. Please remove or move them before running this setup script, or use the --force flag to overwrite them."
    exit 1
  fi
fi


# Small helper to escape characters for sed
escape_sed() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//|/\\|}"
  value="${value//&/\\&}"
  echo "$value"
}

# Function to apply substitutions and copy files
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
  chmod $PERMISSIONS "./flake.nix"
  trap - EXIT
}


# Decode the language and map it to the corresponding flake
case "$LANGUAGE" in
  "jvm")
    if [ "${#LANGUAGE_ARGS[@]}" -lt 1 ]; then
      echo "Error: jvm requires a package argument (e.g., setup-dev jvm jdk17)."
      exit 1
    fi
    VARS[JVM_PACKAGE]="${LANGUAGE_ARGS[0]}"
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
chmod $PERMISSIONS "./.envrc"

echo "Setup completed for language '$LANGUAGE'."