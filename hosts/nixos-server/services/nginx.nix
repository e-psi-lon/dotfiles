{ config, ... }:
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
  };
  users.users.${config.services.nginx.user} = {
    extraGroups = [ "acme" ];
  };
}