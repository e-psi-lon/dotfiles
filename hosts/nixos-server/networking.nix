{ config, ... }:
{
  networking = {
    useDHCP = true;
    firewall = {
      enable = true;
      interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [ 9100 ];
      allowedTCPPorts = [
        80
        443
        8080
        4173
      ];
      # Minecraft server in UDP
      allowedUDPPorts = [ 25565 ];
    };
  };
}
