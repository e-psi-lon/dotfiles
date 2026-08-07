{
  writeShellApplication,
  podman,
  podman-compose,
  composeFile,
}:
writeShellApplication {
  name = "podman-container";
  runtimeInputs = [
    podman
    podman-compose
  ];
  text = ''
    export COMPOSE_FILE="${composeFile}/podman-compose.yml"
    export PROJECT_NAME="podman-containers"
    ${builtins.readFile ./podman-container.sh}
  '';
}
