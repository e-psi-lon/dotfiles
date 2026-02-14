{
  pkgs,
  lib,
  zen-browser,
  nixcord,
  android-nixpkgs,
  paths,
  subPath,
  ...
}:

{
  imports = [
    nixcord.homeModules.nixcord
    android-nixpkgs.hmModule
    (subPath paths.home-modules "common")
    (subPath paths.home-modules "spicetify.nix")
    (subPath paths.home-modules "direnv.nix")
    (subPath paths.home-modules "discord.nix")
    (subPath paths.home-modules "containerisation.nix")
    (subPath paths.home-modules "android.nix")
  ];

  programs.tmux = {
    enable = true;
    reverseSplit = true;
    plugins = with pkgs.tmuxPlugins; [
      prefix-highlight
      yank
      battery
      onedark-theme
      vim-tmux-focus-events
    ];
  };
  programs.fzf.tmux.enableShellIntegration = true;
  programs.nixvim = {
    extraPlugins = with pkgs.vimPlugins; [ 
      onedarkpro-nvim
      vim-tmux-focus-events
    ];
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
      cmp = {
        enable = true;
        autoEnableSource = false;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
      copilot-lua = {
        enable = true;
      };
      copilot-chat = {
        enable = true;
      };
      copilot-cmp = {
        enable = true;
      };
      copilot-lsp = {
        enable = true;
      };
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
    android-studio
    gource

    # Misc
    libreoffice-qt
    proton-pass
    xwayland-satellite

    # Games
    prismlauncher
    ryubing
    dolphin-emu
    melonDS
    azahar
    nestopia-ue
    cemu
    pcsx2
    mgba
    pegasus-frontend

    # Global languages
    nodejs_24
    jdk21
    php

    # Class stuff
    ganttproject-bin
    modelio
  ];
}
