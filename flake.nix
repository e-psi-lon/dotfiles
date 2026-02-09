{
  description = "My NixOS configuration flake. Do I really need to say more??";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    nixcord.url = "github:FlameFlag/nixcord/f381c8e4469072862997d6f66019ebbdf8145963";
    nixos-hardware.url = "github:e-psi-lon/nixos-hardware/feat/asus-fa706ic";
    minegrub-world-sel-theme = {
      url = "github:Lxtharia/minegrub-world-sel-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/prerelease-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "github:nix-community/nixvim";
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      zen-browser,
      spicetify-nix,
      nixcord,
      minegrub-world-sel-theme,
      home-manager,
      nix-on-droid,
      nixos-hardware,
      nixvim,
      android-nixpkgs,
      ...
    }:
    let
      paths = import ./lib/paths.nix;
      subPath = paths.sub;
      inherit (import (subPath paths.lib "mkNixosSystem.nix")) mkNixosSystem;
      commonModule = subPath paths.modules "common";
      overlays = [
        android-nixpkgs.overlays.default
      ];
    in
    {
      nixosConfigurations = {
        nixos-asus = mkNixosSystem {
          pkgs = nixpkgs;
          home-manager = home-manager;
          modules = [
            { nixpkgs.overlays = overlays; }
            commonModule
            (subPath paths.modules "desktop-kde.nix")
            (subPath paths.modules "grub.nix")
            (subPath paths.modules "nvidia.nix")
            (subPath paths.modules "steam.nix")
            (subPath paths.modules "containerisation.nix")
            minegrub-world-sel-theme.nixosModules.default
            nixos-hardware.nixosModules.asus-fa706ic
          ];
          machineName = "asus";
          inherit paths subPath zen-browser spicetify-nix nixcord android-nixpkgs nixvim;
        };

        nixos-hp = mkNixosSystem {
          pkgs = nixpkgs;
          home-manager = home-manager;
          modules = [
            commonModule
            (subPath paths.modules "desktop-lxqt.nix")
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            "${nixos-hardware}/common/cpu/intel/braswell"
          ];
          machineName = "hp";
          inherit paths subPath nixvim;
        };

        nixOnDroidConfiguration = nix-on-droid.lib.nixOnDroidConfiguration {
          pkgs = import nixpkgs { system = "aarch64-linux"; };
          modules = [
            ./hosts/nix-on-droid
          ];
          inherit paths subPath;
        };
      };
    };
}
