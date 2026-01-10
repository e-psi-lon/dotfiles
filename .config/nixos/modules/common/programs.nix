{ lib, ... }:

{
  programs = {
    ssh.startAgent = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    appimage = {
      enable = lib.mkDefault true;
      binfmt = lib.mkDefault true;
    };
  };
}
