{ config, ... }:
{
  networking = {
    useDHCP = true;
    firewall = {
      enable = true;
      interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
         8080
         4173
        ];
      allowedTCPPorts = [
        80
        443
      ];
      # Minecraft server in UDP
      allowedUDPPorts = [ 25565 ];
    };
  };
}
