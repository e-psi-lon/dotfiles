{ pkgs, ... }:

{
  enable = true;
  globals.mapleader = " ";
  keymaps = [
    {
      key = "<leader>et";
      action  = "<cmd>NvimTreeToggle<CR>";
      options.desc = "Toggle file explorer";
    }
    {
      key = "<leader>e";
      action  = "<cmd>NvimTreeFocus<CR>";
      options.desc = "Focus file explorer";
    }
    {
      key = "<leader>as";
      action  = "<cmd>ASToggle<CR>";
      options.desc = "Enable/disable auto-save";
    }
  ];
  plugins = {
    mini-icons = {
      enable = true;
      mockDevIcons = true;
    };
    nvim-tree = {
      enable = true;
      openOnSetup = true;
      autoClose = true;
    };
    auto-save.enable = true;
    treesitter = {
      enable = true;
      highlight.enable = true;
      indent.enable = true;
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        json
        lua
        nix
        make
        markdown
        regex
        toml
        vim
        c
        toml
      ];
    };
  };
}