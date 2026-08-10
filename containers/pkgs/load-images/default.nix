{
  lib,
  writeShellApplication,
  podman,
  coreutils,
  directoriesToCreate,
  sharedDirs,
  enabledImages,
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
    directories_to_create=(
      ${lib.concatStringsSep " " directoriesToCreate}
    )
    declare -A shared_dirs_to_create=(
      ${lib.concatMapStringsSep "\n" (
        d: "\t[${lib.escapeShellArg d.path}]=${toString d.uid}"
      ) sharedDirs}
    )

    declare -A images=(
      ${lib.concatMapStringsSep "\n" (
        img: "\t[\"${img}\"]=${"localhost/${img.imageName}:${img.imageTag}"}"
      ) enabledImages}
    )
    ${builtins.readFile loadImageBase}
  '';
}
