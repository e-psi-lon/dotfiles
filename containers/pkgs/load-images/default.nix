{
  lib,
  writeShellApplication,
  podman,
  coreutils,
  directoriesToCreate,
  sharedDirs,
  enabledImages,
  containerUidGid,
}:
let
  loadImageBase = ./load-images.sh;
in
writeShellApplication {
  name = "load-podman-images";
  runtimeInputs = [
    podman
    coreutils
  ];
  text = ''
    # Ensure all host volume directories exist with current user ownership by creating an array
    CONTAINER_UID_GID=${toString containerUidGid}
    directories_to_create=(
      ${lib.concatStringsSep " " directoriesToCreate}
    )
    shared_dirs_to_create=(
      ${lib.concatStringsSep " " sharedDirs}
    )

    declare -A images=(
      ${lib.concatMapStringsSep "\n" (
        img: "\t[\"${img}\"]=${"localhost/${img.imageName}:${img.imageTag}"}"
      ) enabledImages}
    )
    ${builtins.readFile loadImageBase}
  '';
}
