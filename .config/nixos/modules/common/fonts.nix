{ pkgs, lib, ... }:

{
  fonts.fontconfig = {
    enable = lib.mkDefault true;
    defaultFonts = {
      sansSerif = lib.mkDefault [ "NotoSans Nerd Font" "NotoSans Nerd Font" ];
      monospace = lib.mkDefault [ "JetBrainsMono Nerd Font" ];
      serif = lib.mkDefault [ "NotoSerif Nerd Font" ];
      emoji = lib.mkDefault [ "Noto Color Emoji" ];
    };
  };

  fonts.packages = lib.mkDefault (with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ]);
}
