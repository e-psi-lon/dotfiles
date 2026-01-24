{ pkgs, ...}: 

{

  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./services.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      tpm2-tss
    ];
  };

  nix = {
    optimise.automatic = true;
    settings.trusted-users = [ "root" "e-psi-lon" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "26.05";
}
