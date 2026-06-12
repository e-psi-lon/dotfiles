{ lib, ... }:

{
  imports = [
    ./sops.nix
    ./packages.nix
    ./programs.nix
  ];

  options = {
    username = lib.mkOption { 
      type = lib.types.str;
      description = "The username for the main user of the system.";
    };
    displayName = lib.mkOption { 
      type = lib.types.str; 
      description = "The display name for the main user of the system.";
    };
    paths = {
      secretsDir = lib.mkOption { 
        type = lib.types.path; 
        description = "The path to the secrets directory.";
      };
    };
  };

  config = {
    nixpkgs.config.allowUnfree = lib.mkDefault true;

    nix = {
      gc.automatic = lib.mkDefault true;
      optimise.automatic = lib.mkDefault true;
      settings = {
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [ "nix-command" "flakes" ];
      };
    };
  };
}