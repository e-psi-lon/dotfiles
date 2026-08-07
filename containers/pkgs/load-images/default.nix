{
  lib,
  writeShellApplication,
  podman,
  coreutils,
  directoriesToCreate,
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
    # Ensure all host volume directories exist with current user ownership
    ${lib.concatMapStringsSep "\n" (dir: "mkdir -p \"${dir}\"") directoriesToCreate}

    declare -A images=(
      ${lib.concatMapStringsSep "\n" (
        img: "\t[\"${img}\"]=${"localhost/${img.imageName}:${img.imageTag}"}"
      ) enabledImages}
    )
    ${builtins.readFile loadImageBase}
  '';
}
