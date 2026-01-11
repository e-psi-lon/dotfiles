{ config, pkgs, lib, ... }:

{

  imports = [
    ./boot.nix
    ./nix-ld.nix
    ./hardware-configuration.nix
  ];
  
  environment = {
    systemPackages = with pkgs; [
      jetbrains-toolbox
      bat
      glow
      vesktop
      (discord.override {
        withOpenASAR = true;
        withVencord = true;
      })
      nodejs_25
      gource


      # JDKs
      jdk8
      jdk11
      jdk21
      jdk25

      # Misc utilities
      ripgrep
      fd
      jq
      dust
      usbutils
      proton-pass

    ];
  };

  nix = {
    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };



  system.stateVersion = "26.05";
}
