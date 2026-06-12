{ lib, ... }:

{
  programs = {
    ssh.startAgent = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
  };
}
