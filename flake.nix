{
  description = "My NixOS configuration flake. Do I really need to say more??";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixcord.url = "github:FlameFlag/nixcord";
    nixos-hardware.url = "github:e-psi-lon/nixos-hardware/feat/asus-fa706ic";
    minegrub-world-sel-theme = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/prerelease-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    {
      nixpkgs-unstable,
      nixpkgs-stable,
      zen-browser,
      spicetify-nix,
      nixcord,
      minegrub-world-sel-theme,
      home-manager-unstable,
      home-manager-stable,
      nix-on-droid,
      nixos-hardware,
      ...
    }:
    let
      inherit (import ./lib/mkNixosSystem.nix) mkNixosSystem;
      commonModule = ./modules/common;
      asusModules = [
        commonModule
        ./modules/desktop-kde.nix
        ./modules/grub.nix
        ./modules/nvidia.nix
        ./modules/steam.nix
        minegrub-world-sel-theme.nixosModules.default
        nixos-hardware.nixosModules.asus-fa706ic
      ];
      asusArgs = {
        zen-browser = zen-browser;
        spicetify-nix = spicetify-nix;
        nixcord = nixcord;
      };
    in
    {
      nixosConfigurations = {
        nixos-asus = mkNixosSystem {
          pkgs = nixpkgs-unstable;
          home-manager = home-manager-unstable;
          modules = asusModules;
          machineName = "asus";
          extraArgs = asusArgs // {
            isUnstable = true;
          };
        };

        nixos-asus-stable = mkNixosSystem {
          pkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          modules = asusModules;
          machineName = "asus";
          extraArgs = asusArgs // {
            isUnstable = false;
          };
        };

        nixos-hp = mkNixosSystem {
          pkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          modules = [
            commonModule
            ./modules/desktop-lxqt.nix
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            "${nixos-hardware}/common/cpu/intel/brasswell"
          ];
          machineName = "hp";
        };

        nixOnDroidConfiguration = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import nixpkgs-stable { system = "aarch64-linux"; };
          modules = [
            ./hosts/nix-on-droid
          ];
        };
      };
    };
}
