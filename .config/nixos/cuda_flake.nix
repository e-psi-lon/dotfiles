{
  description = "CUDA Development Environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs }: {
    devShells.x86_64-linux.default = nixpkgs.mkShell {
      buildInputs = with nixpkgs; [
        cuda-cudart
        cudatoolkit
      ];
    };
  };
}