# COMPOSE_FILE is provided as an environment variable by the Nix wrapper.

if [ "$#" -lt 1 ]; then
  echo "Usage: $(basename "$0") <command> <service-name> [args...]"
  echo ""
  echo "Commands (targeted for manual services):"
  echo "  start <service>   Start a manual service"
  echo "  stop <service>    Stop a manual service"
  echo "  logs <service>    View output from a manual service"
  echo "  exec <service> .. Execute a command in a manual service"
  echo "  ps                List all running containers in this stack"
  exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
  start)
    if [ "$#" -lt 1 ]; then
      echo "Error: 'start' requires a service name."
      exit 1
    fi
    SERVICE="$1"
    shift
    exec podman-compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" --profile "manual-$SERVICE" up -d "$SERVICE" "$@"
    ;;
  stop|logs|exec)
    if [ "$#" -ge 1 ]; then
      SERVICE="$1"
      shift
      exec podman-compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" --profile "manual-$SERVICE" "$COMMAND" "$SERVICE" "$@"
    else
      exec podman-compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "$COMMAND" "$@"
    fi
    ;;
  ps)
    exec podman-compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" ps "$@"
    ;;
  up|down)
    echo "Error: Do not manage the entire stack's lifecycle manually."
    echo "Use 'systemctl --user start podman-containers' or 'systemctl --user stop podman-containers' instead."
    exit 1
    ;;
  *)
    # Passthrough any native podman-compose commands
    exec podman-compose -p "$PROJECT_NAME" -f "$COMPOSE_FILE" "$COMMAND" "$@"
    ;;
esac