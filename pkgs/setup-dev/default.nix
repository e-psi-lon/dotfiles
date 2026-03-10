{
  writeShellApplication,
  paths
}:
let 
  flakes = paths.dev-flakes;
  envrc = paths.subPath paths.resources ".envrc";
in writeShellApplication {
  name = "setup-dev";
  text = ''
    ENVRC_FILE="${envrc}"
    FLAKE_DIR="${flakes}"

    ${builtins.readFile ./setup.sh}
  '';
}