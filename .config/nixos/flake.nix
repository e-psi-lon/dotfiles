{
    description = "My NixOS configuration flake. Do I really need to say more??";
    
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
        zen-browser.url = "github:youwen5/zen-browser-flake";
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        nixcord.url = "github:kaylorben/nixcord";
        minegrub-world-sel-theme = {
            url = "github:Lxtharia/minegrub-world-sel-theme";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
        home-manager-unstable = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        home-manager-stable = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
    };

    outputs = { self, nixpkgs-unstable, nixpkgs-stable, zen-browser, spicetify-nix, nixcord, minegrub-world-sel-theme, home-manager-unstable, home-manager-stable, ... }:
    let
        mkNixosSystem = { pkgs, home-manager, modules, machineName, extraArgs ? {} }:
            pkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = extraArgs;
                modules = modules ++ [
                    ./hosts/nixos-${machineName}
                    { networking.hostName = "nixos-${machineName}"; }
                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.e-psi-lon = ./home/home-${machineName}.nix;
                        home-manager.extraSpecialArgs = extraArgs;
                    }
                ];
            };
        commonModule = ./modules/common;
        asusModules = [
            commonModule
            ./modules/desktop-kde.nix
            ./modules/grub.nix
            ./modules/nvidia.nix
            ./modules/steam.nix
            minegrub-world-sel-theme.nixosModules.default
        ];
        asusArgs = { zen-browser = zen-browser; spicetify-nix = spicetify-nix; };
    in
    {
        nixosConfigurations = {
            nixos-asus = mkNixosSystem {
                pkgs = nixpkgs-unstable;
                home-manager = home-manager-unstable;
                modules = asusModules;
                machineName = "asus";
                extraArgs = asusArgs // { isUnstable = true; };
            };

            nixos-asus-stable = mkNixosSystem {
                pkgs = nixpkgs-stable;
                home-manager = home-manager-stable;
                modules = asusModules;
                machineName = "asus";
                extraArgs = asusArgs // { isUnstable = false; };
            };

            nixos-hp = mkNixosSystem {
                pkgs = nixpkgs-stable;
                home-manager = home-manager-stable;
                modules = [
                    commonModule
                    ./modules/desktop-lxqt.nix
                ];
                machineName = "hp";
            };
        };
    };
}
