{ config, ... }:
{
  networking = {
    useDHCP = false;
    interfaces.ens3 = {
      ipv4.addresses = [
        {
          address = "62.83.96.192";
          prefixLength = 22;
        }
      ];
      ipv6.addresses = [
        {
          address = "2a03:4000:15:124d:9432:29ff:fe40:71e5";
          prefixLength = 64;
        }
      ];
    };
    defaultGateway = {
      address = "62.83.96.1";
      interface = "ens3";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "ens3";
    };
    nameservers = [
      "46.38.252.230"
      "46.38.225.230"
      "2a03:4000:8000::fce6"
    ];
    firewall = {
      enable = true;
      interfaces.${config.services.tailscale.interfaceName}.allowedTCPPorts = [
        8080
        4173
        9100
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
