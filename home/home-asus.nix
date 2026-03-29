{
  pkgs,
  config,
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
    (subPath paths.home-modules "mcp.nix")
  ];

  hasNvidiaGpu = true;
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
        action = "<cmd>MarkdownPreview toggle<CR>";
        options.desc = "Toggle markdown preview";
      }
    ];
    plugins = {
      render-markdown = {
        enable = true;
        settings = {
          heading = {
            icons = [
              "# "
              "## "
              "### "
              "#### "
              "##### "
              "###### "
            ];
          };
          bullets = {
            icons = [
              "• "
              "◦ "
              "▪ "
            ];
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
    setup-dev # Custom script to setup a dev environment with direnv and a flake
    sl # Yes.

    # Games
    prismlauncher
    ryubing
    dolphin-emu
    melonds
    azahar
    nestopia-ue
    cemu
    pcsx2
    mgba
    pegasus-frontend
    steam-rom-manager

    # Global languages
    nodejs_24
    php

    # Class stuff
    ganttproject-bin
    modelio
  ];

  home.file =
    let
      xdgConfig = config.xdg.configHome;
      xdgData = config.xdg.dataHome;
      emulation = "/mnt/data/Emulation";
      jdkHome = pkg: subPath pkg "lib/openjdk";
      emuPath = rel: config.lib.file.mkOutOfStoreSymlink "${emulation}/${rel}";
    in
    {
      ".jdks/jdk21".source = jdkHome pkgs.jdk21;
      ".jdks/jdk25".source = jdkHome pkgs.jdk25;
      ".jdks/jdk17".source = jdkHome pkgs.jdk17;
      ".jdks/jdk8".source = jdkHome pkgs.jdk8;

      "Desktop/Zen Browser.desktop".source =
        subPath zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
          "share/applications/zen.desktop";

      # Emulators
      ## Ryujinx
      "${xdgConfig}/Ryujinx/bis".source = emuPath "saves/ryujinx";
      "${xdgConfig}/Ryujinx/games".source = emuPath "storage/ryujinx/games";
      "${xdgConfig}/Ryujinx/mods".source = emuPath "storage/ryujinx/mods";
      "${xdgConfig}/Ryujinx/sdcard".source = emuPath "storage/ryujinx/sdcard";
      "${xdgConfig}/Ryujinx/system".source = emuPath "bios/ryujinx";

      ## Dolphin
      "${xdgData}/dolphin-emu/Dump".source = emuPath "storage/dolphin/Dump";
      "${xdgData}/dolphin-emu/GC".source = emuPath "saves/dolphin/GC";
      "${xdgData}/dolphin-emu/Load".source = emuPath "storage/dolphin/Load";
      "${xdgData}/dolphin-emu/ResourcePacks".source = emuPath "texturepacks/dolphin/ResourcePacks";
      "${xdgData}/dolphin-emu/ScreenShots".source = emuPath "storage/dolphin/ScreenShots";
      "${xdgData}/dolphin-emu/StateSaves".source = emuPath "saves/dolphin/StateSaves";
      "${xdgData}/dolphin-emu/WFS".source = emuPath "storage/dolphin/WFS";
      "${xdgData}/dolphin-emu/Wii".source = emuPath "saves/dolphin/Wii";

      ## Azahar
      "${xdgData}/azahar-emu/sysdata".source = emuPath "bios/azahar";
      "${xdgData}/azahar-emu/cheats".source = emuPath "storage/azahar/cheats";
      "${xdgData}/azahar-emu/nand".source = emuPath "storage/azahar/nand";
      "${xdgData}/azahar-emu/screenshots".source = emuPath "storage/azahar/screenshots";
      "${xdgData}/azahar-emu/sdmc".source = emuPath "saves/azahar/sdmc";
      "${xdgData}/azahar-emu/states".source = emuPath "saves/azahar/states";

      ## Cemu
      "${xdgData}/Cemu/mlc01/sys".source = emuPath "storage/Cemu";
      "${xdgData}/Cemu/mlc01/usr".source = emuPath "saves/Cemu";
      "${xdgData}/Cemu/graphicPacks".source = emuPath "texturepacks/Cemu";
    };
}
