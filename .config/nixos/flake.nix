{
    description = "e-psi-lon's NixOS config across all my devices";
    
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
        zen-browser.url = "github:youwen5/zen-browser-flake";
        minegrub-world-sel-theme = {
            url = "github:Lxtharia/minegrub-world-sel-theme";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
    };

    outputs = { self, nixpkgs-unstable, nixpkgs-stable, zen-browser, minegrub-world-sel-theme, ... }:
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
        ./modules/common.nix
      ];
      asusModules = commonModules ++ [
        ./modules/desktop-kde.nix
        ./modules/grub.nix
        ./modules/nvidia.nix
        ./modules/zen-browser.nix
        ./hosts/nixos-asus.nix
        # ./hosts/nixos-asus/hardware-configuration.nix
        minegrub-world-sel-theme.nixosModules.default
      ];
    in
    {
        nixosConfigurations = {
            nixos-asus = mkNixosSystem {
                pkgs = nixpkgs-unstable;
                modules = asusModules;
                hostName = "nixos-asus";
                extraArgs = {  zen-browser = zen-browser;  };
            };

            nixos-asus-stable = mkNixosSystem {
                pkgs = nixpkgs-stable;
                modules = asusModules;
                hostName = "nixos-asus";
                extraArgs = {  zen-browser = zen-browser;  };
            };

            nixos-hp = mkNixosSystem {
                pkgs = nixpkgs-stable;
                modules = commonModules ++ [
                    ./modules/desktop-lxqt.nix
                    ./hosts/nixos-hp.nix
                    ./hosts/nixos-hp/hardware-configuration.nix
                ];
                hostName = "nixos-hp";
            };
        };
    };
}
