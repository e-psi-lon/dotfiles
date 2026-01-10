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
        mkNixosSystem = { pkgs, modules, hostName, extraArgs ? {} }:
            pkgs.lib.nixosSystem {
                system = "x86_64-linux";
                specialArgs = extraArgs;
                modules = modules ++ [
                    { networking.hostName = hostName; }
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
            ./modules/spicetify.nix
            ./modules/zen-browser.nix
            ./hosts/nixos-asus
            minegrub-world-sel-theme.nixosModules.default
        ];
    in
    {
        nixosConfigurations = {
            nixos-asus = mkNixosSystem {
                pkgs = nixpkgs-unstable;
                modules = asusModules;
                hostName = "nixos-asus";
                extraArgs = {  zen-browser = zen-browser;  isUnstable = true;  spicetify-nix = spicetify-nix; };
            };

            nixos-asus-stable = mkNixosSystem {
                pkgs = nixpkgs-stable;
                modules = asusModules;
                hostName = "nixos-asus";
                extraArgs = {  zen-browser = zen-browser;  isUnstable = false;  spicetify-nix = spicetify-nix; };
            };

            nixos-hp = mkNixosSystem {
                pkgs = nixpkgs-stable;
                modules = commonModules ++ [
                    ./modules/desktop-lxqt.nix
                    ./hosts/nixos-hp
                ];
                hostName = "nixos-hp";
            };
        };
    };
}
