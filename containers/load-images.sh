STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/containers"
mkdir -p "$STATE_DIR"
mkdir -p "$STATE_DIR/loaded-images"


# Lock the files after use to prevent accidental modification between runs.
lock_state() {
  chmod 000 "$STATE_DIR/loaded-images"/* 2>/dev/null || true
  chmod 100 "$STATE_DIR/loaded-images" 2>/dev/null || true
}

trap 'lock_state' EXIT INT TERM HUP

# Unlock for the duration of the script
chmod 700 "$STATE_DIR"
chmod 700 "$STATE_DIR"/loaded-images
chmod 400 "$STATE_DIR"/loaded-images/* 2>/dev/null || true

declare -A current_hashes
for img in "${images[@]}"; do
  current_hashes["$(basename "$img")"]=1
done

for mark in "$STATE_DIR/loaded-images/"*.loaded; do
  [ -e "$mark" ] || continue
  base_hash="$(basename "$mark" .loaded)"
  if [[ -z "${current_hashes[$base_hash]:-}" ]]; then
    echo "Cleaning up outdated image marker: $base_hash"
    rm -f "$mark"
  fi
done

for i in "${!images[@]}"; do
  img="${images[$i]}"
  ref="${image_refs[$i]}"
  img_hash="$(basename "$img")"
  marker_file="$STATE_DIR/loaded-images/$img_hash.loaded"
  
  if [ -f "$marker_file" ]; then
    expected_id=$(cat "$marker_file")
    
    current_id=$(podman image inspect --format '{{.Id}}' "$ref" 2>/dev/null || true)

    if [ -n "$current_id" ] && [[ "$current_id" == "$expected_id" ]]; then
      echo "Image $img_hash is up to date in podman. Skipping load."
      continue
    fi
    echo "Image $img_hash missing from podman storage. Reloading..."
  fi

  echo "Streaming new image to podman: $img"
  "$img" | podman load
  loaded_id=$(podman image inspect --format '{{.Id}}' "$ref")

  if [[ -z "$loaded_id" ]]; then
    echo "Error: Failed to load image $img_hash into podman or extract digest."
    continue
  fi

  echo "$loaded_id" > "$marker_file"
done

declare -A current_refs
declare -A managed_names
for ref in "${image_refs[@]}"; do
  current_refs["$ref"]=1
  managed_names["${ref%%:*}"]=1
done

for ref in $(podman images --format "{{.Repository}}:{{.Tag}}"); do
  name="${ref%%:*}"
  if [[ -n "${managed_names[$name]:-}" ]] && [[ -z "${current_refs[$ref]:-}" ]]; then
    echo "Removing stale image: $ref"
    podman rmi "$ref" || true
  fi
done
