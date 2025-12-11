{
    description = "e-psi-lon's NixOS config accross all my devices";
    
    inputs = {
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
	nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
	zen-browser.url = "github:youwen5/zen-browser-flake";
    };

    outputs = { self, nixpkgs-unstable, nixpkgs-stable, zen-browser, ... }: {
        nixosConfigurations = {
            nixos-asus = nixpkgs-unstable.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./modules/common.nix
                    ./modules/desktop-kde.nix
                    ./hosts/nixos-asus.nix
                ];
            };
            nixos-hp = nixpkgs-stable.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./modules/common.nix
                    ./modules/desktop-lxqt.nix
                    ./hosts/nixos-hp.nix
		    ./hosts/nixos-hp/hardware-configuration.nix
                ];

            };
        };
    };
}
