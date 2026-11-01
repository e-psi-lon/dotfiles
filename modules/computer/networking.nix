{ config, lib, ... }:

{
  services = {
    resolved.enable = lib.mkDefault true;
    tailscale = {
      enable = lib.mkDefault true;
      useRoutingFeatures = lib.mkDefault "both";
      permitCertUid = lib.mkDefault (toString config.personalId);
      # Once Tailscale fixes their SSH implementation this could be re-enabled
      # extraSetFlags = [ "--ssh" ];
    };
  };
}
