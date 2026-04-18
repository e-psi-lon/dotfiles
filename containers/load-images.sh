STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/containers"
mkdir -p "$STATE_DIR"

# 1. Gather all current valid hashes into an array
declare -A current_hashes
for img in "${images[@]}"; do
  current_hashes["$(basename "$img")"]=1
done

# 2. Clean up obsolete markers to prevent directory bloat
for mark in "$STATE_DIR/loaded-images/"*.loaded; do
  [ -e "$mark" ] || continue
  base_hash="$(basename "$mark" .loaded)"
  if [[ -z "${current_hashes[$base_hash]:-}" ]]; then
    echo "Cleaning up outdated image marker: $base_hash"
    rm -f "$mark"
  fi
done

# 3. Load only the new or missing images
mkdir -p "$STATE_DIR/loaded-images"
for img in "${images[@]}"; do
  img_hash="$(basename "$img")"
  
  if [ -f "$STATE_DIR/loaded-images/$img_hash.loaded" ]; then
    echo "Image $img_hash is up to date."
    continue
  fi

  echo "Streaming new image to podman: $img"
  "$img" | podman load

  # Mark as perfectly loaded
  touch "$STATE_DIR/loaded-images/$img_hash.loaded"
done

# 4. Clean up the Podman storage block bloat!
# When an image is updated, the old one is still there but we definitely don't want to keep it around.
declare -A current_refs
declare -A managed_names
for ref in "${image_refs[@]}"; do
  current_refs["$ref"]=1
  managed_names["${ref%%:*}"]=1  # extract just the name part before ':'
done

for ref in $(podman images --format "{{.Repository}}:{{.Tag}}"); do
  name="${ref%%:*}"
  if [[ -n "${managed_names[$name]:-}" ]] && [[ -z "${current_refs[$ref]:-}" ]]; then
    echo "Removing stale image: $ref"
    podman rmi "$ref" || true
  fi
done