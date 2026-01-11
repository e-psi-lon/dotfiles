{
    description = "My NixOS configuration flake. Do I really need to say more??";
    
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
        zen-browser.url = "github:youwen5/zen-browser-flake";
        minegrub-world-sel-theme = {
            url = "github:Lxtharia/minegrub-world-sel-theme";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
        spicetify-nix.url = "github:Gerg-L/spicetify-nix";
        home-manager-unstable = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-unstable";
        };
        home-manager-stable = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
    };

    outputs = { self, nixpkgs-unstable, nixpkgs-stable, zen-browser, minegrub-world-sel-theme, spicetify-nix, home-manager-unstable, home-manager-stable, ... }:
    let
        mkNixosSystem = { pkgs, home-manager, modules, hostName, extraArgs ? {}, home }:
            pkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = extraArgs;
                modules = modules ++ [
                    { networking.hostName = hostName; }
                    home-manager.nixosModules.home-manager
                    {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.users.e-psi-lon = home;
                        home-manager.extraSpecialArgs = extraArgs;
                    }
                ];
            };
        commonModules = [
            ./modules/common
            ./modules/packages.nix
        ];
        asusModules = commonModules ++ [
            ./modules/desktop-kde.nix
            ./modules/grub.nix
            ./modules/nvidia.nix
            ./modules/gaming.nix
            ./hosts/nixos-asus
            minegrub-world-sel-theme.nixosModules.default
        ];
    in
    {
        nixosConfigurations = {
            nixos-asus = mkNixosSystem {
                pkgs = nixpkgs-unstable;
                home-manager = home-manager-unstable;
                modules = asusModules;
                hostName = "nixos-asus";
                home = ./home/home-asus.nix;
                extraArgs = {  zen-browser = zen-browser;  isUnstable = true;  spicetify-nix = spicetify-nix; };
            };

            nixos-asus-stable = mkNixosSystem {
                pkgs = nixpkgs-stable;
                home-manager = home-manager-stable;
                modules = asusModules;
                hostName = "nixos-asus";
                home = ./home/home-asus.nix;
                extraArgs = {  zen-browser = zen-browser;  isUnstable = false;  spicetify-nix = spicetify-nix; };
            };

            nixos-hp = mkNixosSystem {
                pkgs = nixpkgs-stable;
                home-manager = home-manager-stable;
                home = ./home/home-hp.nix;
                modules = commonModules ++ [
                    ./modules/desktop-lxqt.nix
                    ./hosts/nixos-hp
                ];
                hostName = "nixos-hp";
            };
        };
    };
}
