{
  pkgs,
  lib,
  zen-browser,
  nixcord,
  paths,
  subPath,
  ...
}:

{
  imports = [
    nixcord.homeModules.nixcord
    (subPath paths.home-modules "common")
    (subPath paths.home-modules "spicetify.nix")
    (subPath paths.home-modules "direnv.nix")
    (subPath paths.home-modules "discord.nix")
    (subPath paths.home-modules "containerisation.nix")
  ];

  programs.tmux.enable = true;
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [ onedarkpro-nvim ];
    colorscheme = "onedark_vivid";
    keymaps = [
      {
        key = "<leader>mp";
        action  = "<cmd>MarkdownPreview toggle<CR>";
        options.desc = "Toggle markdown preview";
      }
    ];
    plugins = {
      render-markdown = {
        enable = true;
        settings = {
          heading = {
            icons = [ "# " "## " "### " "#### " "##### " "###### " ];
          };
          bullets = {
            icons = [ "• " "◦ " "▪ " ];
          };
          enabled = true;
          debounce = 100;
        };
      };
      treesitter.grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        cpp
        java
        python
        html
        css
        javascript
        typescript
        php
        xml
        yaml
      ];
    };
  };

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
