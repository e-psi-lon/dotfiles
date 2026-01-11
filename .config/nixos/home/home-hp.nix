{ config, pkgs, ... }:

let 
  modules = ../home-modules;
in
{

  imports = [
    (modules + /common.nix)
  ];


  home.packages = with pkgs; [
    firefox
    moonlight-qt
    # CONSIDER: Keep some local RetroArch vs. 100% remote streaming. Local might not be useful
    (retroarch.withCores(cores: with cores; [
        nestopia
        gambatte
        mgba
    ]))
  ];
}