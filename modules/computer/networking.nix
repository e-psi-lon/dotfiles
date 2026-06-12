{ config, lib, ... }:

{
  config.services = {
    resolved.enable = lib.mkDefault true;
    tailscale = {
      enable = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "both";
      permitCertUid = lib.mkDefault config.username;
      # Once Tailscale fixes their SSH implementation this could be re-enabled
      # extraSetFlags = [ "--ssh" ];
    };
  };
}
