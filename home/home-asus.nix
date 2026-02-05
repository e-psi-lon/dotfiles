{
  pkgs,
  lib,
  nixvim,
  zen-browser,
  nixcord,
  paths,
  subPath,
  ...
}:

{
  imports = [
    nixcord.homeModules.nixcord
    nixvim.homeModules.nixvim
    (subPath paths.home-modules "common")
    (subPath paths.home-modules "spicetify.nix")
    (subPath paths.home-modules "direnv.nix")
    (subPath paths.home-modules "discord.nix")
    (subPath paths.home-modules "containerisation.nix")
  ];

  programs.tmux.enable = true;
  programs.nixvim.imports = [
    (subPath paths.home-modules "neovim.nix")
     {
      extraPlugins = with pkgs.vimPlugins; [ onedarkpro-nvim ];
      colorscheme = "onedark_vivid";
    }
  ];

  programs.zsh.initContent = ''
    [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(${lib.getExe pkgs.vscode} --locate-shell-integration-path zsh)"
  '';

  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    # Web browser
    zen-browser.packages.${stdenv.hostPlatform.system}.default
    ungoogled-chromium # Required for some APIs Firefox (and forks) doesn't support...

    # IDEs, text editor and other dev tools
    vscode
    nixfmt
    nixd
    jetbrains-toolbox
    jetbrains.idea
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.clion
    gource

    # Misc
    libreoffice-qt
    prismlauncher
    proton-pass
    xwayland-satellite

    # Global languages
    nodejs_24
    jdk21
    php

    # Class stuff
    ganttproject-bin
  ];
}
