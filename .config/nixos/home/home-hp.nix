{ config, pkgs, zen-browser, spicetify-nix, ... }:

{

  imports = [
    ../home-modules/common.nix
  ];


  home.packages = with pkgs; [
  ];
}