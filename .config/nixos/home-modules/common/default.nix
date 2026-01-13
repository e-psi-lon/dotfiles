{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
  ];

  home = {
    username = "e-psi-lon";
    homeDirectory = "/home/e-psi-lon";
  };

  programs = {
    zsh.enable = true;
    git.lfs.enable = true;
  };
}