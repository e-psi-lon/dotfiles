{ config, lib, ... }:

{
  config = {
    networking = {
      networkmanager.enable = lib.mkDefault true;
      resolvconf.enable = lib.mkDefault false;
    };
    users.users.${config.username}.extraGroups = lib.mkDefault [ "networkmanager" ];
  };
}