{ nixvim, ... }:
{
  imports = [
    nixvim.homeModules.nixvim
    ./zsh.nix
    ./git.nix
    ./terminal.nix
    ./fastfetch.nix
  ];

  programs.nixvim.imports = [ ./neovim.nix ];  
}
