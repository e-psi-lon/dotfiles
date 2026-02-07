{ pkgs, ... }:

{
  enable = true;
  globals.mapleader = " ";
  keymaps = [
    {
      key = "<leader>tt";
      action  = "<cmd>NvimTreeToggle<CR>";
      options.desc = "Toggle file explorer";
    }
    # TODO: Find a meaningful keybind for exiting terminal mode
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
  vimAlias = true;
  opts = {
    number = true;
    shiftwidth = 4;
  };
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