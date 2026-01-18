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
      paths = import ./lib/paths.nix;
      subPath = paths.sub;
      inherit (import subPath paths.lib "mkNixosSystem.nix") mkNixosSystem;
      commonModule = subPath paths.modules "common";
      asusModules = [
        commonModule
        (subPath paths.modules "desktop-kde.nix")
        (subPath paths.modules "grub.nix")
        (subPath paths.modules "nvidia.nix")
        (subPath paths.modules "steam.nix")
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
          inherit paths subPath;
          extraArgs = asusArgs // {
            isUnstable = true;
          };
        };

        nixos-asus-stable = mkNixosSystem {
          pkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          modules = asusModules;
          machineName = "asus";
          inherit paths subPath;
          extraArgs = asusArgs // {
            isUnstable = false;
          };
        };

        nixos-hp = mkNixosSystem {
          pkgs = nixpkgs-stable;
          home-manager = home-manager-stable;
          modules = [
            commonModule
            (subPath paths.modules "desktop-lxqt.nix")
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            "${nixos-hardware}/common/cpu/intel/brasswell"
          ];
          machineName = "hp";
          inherit paths subPath;
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
