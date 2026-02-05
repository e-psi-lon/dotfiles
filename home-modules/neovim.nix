{ pkgs, ... }:

{
  enable = true;
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
        vimdoc
        xml
        yaml
        python
        c
        cpp
        java
        html
        css
        javascript
        typescript
        php
        toml

      ];
    };
  };
}