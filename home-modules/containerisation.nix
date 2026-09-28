{ pkgs, lib, ... }: {
  services.podman = {
    enable = true;
  };

  home = {
    packages = with pkgs; [
      podman-compose
      podman-desktop
      podman-tui
    ];
    sessionVariables.PODMAN_COMPOSE_PROVIDER = lib.getExe pkgs.podman-compose;
  };
}
