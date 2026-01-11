{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
  ];

  home = {
    username = "e-psi-lon";
    homeDirectory = "/home/e-psi-lon";
    stateVersion = "26.05";
  };

  programs = {
    zsh.enable = true;
    git.lfs.enable = true;
  };
}