{
  description = "This is a JVM-based project.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-{{NIXPKGS_VERSION}}";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      project-jdk = pkgs.{{JVM_PACKAGE}};
    in {
      devShells.${system}.default = pkgs.mkShell {
          shellHook = ''
              ln -sfn ${project-jdk}/lib/openjdk .jdk
              export JAVA_HOME=$PWD/.jdk
              
              if command -v git &>/dev/null && [ -d .git ]; then
                if ! git check-ignore -q .jdk 2>/dev/null; then
                  echo "Warning: .jdk is not git-ignored. Consider adding it to .gitignore."
                fi
              elif [ -f .gitignore ] && ! grep -q "^\.jdk" .gitignore; then
                echo "Warning: .jdk is not in .gitignore. Consider adding it to .gitignore."
              fi
          '';
          nativeBuildInputs = [
            project-jdk
          ];
        };
    };
}