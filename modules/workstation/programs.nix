{ lib, ... }:
{
  programs.appimage = {
    enable = lib.mkDefault true;
    binfmt = lib.mkDefault true;
  };
}