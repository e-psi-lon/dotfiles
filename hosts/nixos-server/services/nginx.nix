{ config, ... }:
{
  services.nginx = {
    enable = true;
  };
  users.users.${config.services.nginx.user} = {
    extraGroups = [ "acme" ];
  };
}