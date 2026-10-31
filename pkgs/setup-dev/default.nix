{ writeShellApplication, paths }:
let
  flakes = paths.resources + "/dev-flakes";
  envrc = paths.resources + "/.envrc";
in
writeShellApplication {
  name = "setup-dev";
  text = ''
    ENVRC_FILE="${envrc}"
    FLAKE_DIR="${flakes}"

    ${builtins.readFile ./setup.sh}
  '';
}
