{ config, lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = lib.mkDefault false;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  users.users.${config.username}.autoSubUidGidRange = true;

}
