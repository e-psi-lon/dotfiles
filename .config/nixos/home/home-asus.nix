{ config, pkgs, zen-browser, spicetify-nix, ... }:

let 
  modules = ../home-modules;
in {

  imports = [
    (modules + /common)
    (modules + /spicetify.nix)
  ];


  home.packages = with pkgs; [
    # Web browser
    zen-browser.packages.${stdenv.hostPlatform.system}.default
    ungoogled-chromium # Required for some APIs Firefox (and forks) doesn't support...
    

    # Discord
    vesktop
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })

    # IDEs and text editor
    vscode
    jetbrains-toolbox

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