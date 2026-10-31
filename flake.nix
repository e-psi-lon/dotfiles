{
  description = "My NixOS configuration flake. Do I really need to say more??";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:FlameFlag/nixcord";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-packages.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.flake-parts.follows = "flake-parts";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kobweb-cli = {
      url = "github:varabyte/kobweb-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
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
      sops-nix,
      claude-desktop,
      kobweb-cli,
      impermanence,
      disko,
      ...
    }:
    let
      paths = import ./lib/paths.nix;
      inherit (import (paths.lib + "/mkNixosSystem.nix")) mkNixosSystem;
      baseModule = paths.modules + "/base";
      computerModule = paths.modules + "/computer";
      workstationModule = paths.modules + "/workstation";
      hashesFile = paths.resources + "/hashes.toml";
      hashes = fromTOML (builtins.readFile hashesFile);
      customPkgs = import paths.custom-pkgs { inherit paths hashes; };
      overlays = [
        android-nixpkgs.overlays.default
        claude-desktop.overlays.default
        kobweb-cli.overlays.default
        customPkgs
      ];
      flakeRev = self.shortRev or "dirty-${toString self.lastModified}";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system overlays; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.callPackage ./shell.nix { };
      });
      nixosConfigurations = {
        nixos-asus = mkNixosSystem {
          home-manager = home-manager;
          modules = [
            { nixpkgs.overlays = overlays; }
            workstationModule
            (paths.modules + "/desktop-kde.nix")
            (paths.modules + "/grub.nix")
            (paths.modules + "/nvidia.nix")
            (paths.modules + "/steam.nix")
            (paths.modules + "/containerisation.nix")
            (paths.modules + "/waydroid.nix")
            (paths.modules + "/virtualisation.nix")
            (paths.modules + "/virtiofsd.nix")
            minegrub-world-sel-theme.nixosModules.default
            disko.nixosModules.disko
            nixos-hardware.nixosModules.asus-fa706ic
          ];
          machineName = "asus";
          inherit
            nixpkgs
            paths
            flakeRev
            zen-browser
            spicetify-nix
            nixcord
            android-nixpkgs
            nixvim
            sops-nix
            hashes
            ;
        };

        nixos-hp = mkNixosSystem {
          home-manager = home-manager;
          modules = [
            workstationModule
            (paths.modules + "/desktop-lxqt.nix")
            (paths.modules + "/limine.nix")
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd # Also works for eMMC
            disko.nixosModules.disko
            (nixos-hardware + "/common/cpu/intel/braswell")
          ];
          machineName = "hp";
          inherit
            nixpkgs
            paths
            flakeRev
            nixvim
            sops-nix
            hashes
            ;
        };
        nixos-server = mkNixosSystem {
          system = "aarch64-linux";
          home-manager = home-manager;
          modules = [
            computerModule
            (paths.modules + "/containerisation.nix")
            (paths.modules + "/limine.nix")
            disko.nixosModules.disko
          ];
          machineName = "server";
          inherit
            nixpkgs
            paths
            flakeRev
            nixvim
            sops-nix
            hashes
            ;
        };
      };
      nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
        pkgs = import nixpkgs { system = "aarch64-linux"; };
        modules = [
          baseModule
          (paths.hosts + "/nix-on-droid") # Currently empty
        ];
        extraSpecialArgs = { inherit paths flakeRev; };
      };
    };
}
