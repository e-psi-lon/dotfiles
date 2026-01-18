{
  pkgs,
  ...
}:

{

  imports = [
    ./boot.nix
    ./nix-ld.nix
    ./hardware-configuration.nix
    ./services.nix
  ];

  # environment = {
  #  systemPackages = with pkgs; [ ];
  # };

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
