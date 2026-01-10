{ lib, ... }:

{
  networking = {
    networkmanager.enable = lib.mkDefault true;
    resolvconf.enable = lib.mkDefault false;
  };

  services.resolved.enable = lib.mkDefault true;

  services.tailscale = {
    enable = lib.mkDefault true;
    useRoutingFeatures = lib.mkDefault "both";
    permitCertUid = lib.mkDefault "e-psi-lon";
  };
}
