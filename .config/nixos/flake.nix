{
    description = "e-psi-lon's NixOS config accross all my devices";
    
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        zen-browser.url = "github:youwen5/zen-browser-flake";
    };

    outputs = { self, nixpkgs }: {
        nixosConfigurations = {
            nixos-asus = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./modules/common.nix
                    ./modules/desktop-kde.nix
                    ./hosts/nixos-asus.nix
                ];
            };
            nixos-hp = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./modules/common.nix
                    ./modules/desktop-lxqt.nix
                    ./hosts/nixos-hp.nix
                ];

            };
        };
    };
}