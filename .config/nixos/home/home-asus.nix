{ config, pkgs, zen-browser, spicetify-nix, ... }:

let 
  modules = ../home-modules;
in {

  imports = [
    (modules + /common.nix)
    (modules + /spicetify.nix)
  ];


  home.packages = with pkgs; [
    zen-browser.packages.${stdenv.hostPlatform.system}.default
    vscode
    ungoogled-chromium # Required for some APIs Firefox doesn't support...
    libreoffice-qt
    prismlauncher
  ];
}