{ pkgs, zen-browser, nixcord, ... }:

let 
  modules = ../home-modules;
in {

  imports = [
    nixcord.homeModules.nixcord
    (modules + /common)
    (modules + /spicetify.nix)
    (modules + /direnv.nix)
    (modules + /discord.nix)
  ];
  
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    # Web browser
    zen-browser.packages.${stdenv.hostPlatform.system}.default
    ungoogled-chromium # Required for some APIs Firefox (and forks) doesn't support...
    

    # Discord

    # IDEs and text editor and other dev tools
    vscode
    nixfmt
    nixd
    jetbrains-toolbox
    jetbrains.idea
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.clion
    gource

    libreoffice-qt
    prismlauncher

    # Misc 
    proton-pass

    # Global languages
    nodejs_24
    jdk21
    php
  ];
}