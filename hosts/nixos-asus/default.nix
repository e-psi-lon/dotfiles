{ pkgs, config, ... }:

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

  users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
    home-hp
    home-asus # Trust itself
  ];
  services.desktopManager.plasma6.notoPackage = pkgs.nerd-fonts.noto;
  services.joycond.enable = true;

  programs.fuse.enable = true;

  nix = {
    optimise.automatic = true;
    settings.trusted-users = [
      "root"
      config.username
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  system.stateVersion = "26.05";
}
