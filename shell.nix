{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = [
    (pkgs.writeShellScriptBin "update-flake" ''
      exec nix flake update --commit-lock-file --commit-lockfile-summary \
        "flake: Update flake inputs to their latest versions"
    '')
    (pkgs.writeShellScriptBin "test-rebuild" ''
      exec sudo nixos-rebuild test --flake .
    '')
    (pkgs.writeShellScriptBin "switch-rebuild" ''
      exec sudo nixos-rebuild switch --flake .
    '')
    (pkgs.writeShellScriptBin "boot-rebuild" ''
      exec sudo nixos-rebuild boot --flake .
    '')
    (pkgs.writeShellScriptBin "check" ''
      exec nix flake check
    '')
  ];
}
