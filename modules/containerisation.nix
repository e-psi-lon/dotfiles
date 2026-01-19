{ lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = lib.mkDefault false;
    dockerCompat = true;
  };
}