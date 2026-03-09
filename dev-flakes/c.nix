{
  description = "This is a C project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-{{NIXPKGS_VERSION}}";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
          shellHook = ''
            
          '';
          nativeBuildInputs = with pkgs; [
            gcc
            cmake
            gnumake
            gdb
            binutils
            pkg-config
            valgrind
            bear
          ];
        };
    };
}