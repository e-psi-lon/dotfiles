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
# When an image is updated, the old one loses its "latest" tag and becomes <none>:<none>.
# This safely deletes those dangling gigabytes without touching actively running containers.
podman image prune -f
