{ pkgs, ...}: 

{

  imports = [
    ./boot.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./services.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      tpm2-tss
    ];
  };
  services.desktopManager.plasma6.notoPackage = pkgs.nerd-fonts.noto;

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
