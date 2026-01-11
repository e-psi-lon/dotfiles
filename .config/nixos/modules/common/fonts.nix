{ pkgs, lib, ... }:

{
  fonts.fontconfig = {
    enable = lib.mkDefault true;
    defaultFonts = lib.mkDefault {
      sansSerif = [ "NotoSans Nerd Font" "NotoSans Nerd Font" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      serif = [ "NotoSerif Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  fonts.packages = (with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ]);
}
