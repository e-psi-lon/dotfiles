{ pkgs, ... }:

{
  programs.nixcord = {
    enable = true;
    discord.enable = true;
    openASAR = true;
    quickCss = ''

    '';
    vesktop = {
      enable = true;
      autoscroll.enable = true;
    };

    config = {
      useQuickCss = true;
      themes = [];
      themeLinks = [];
      enabledThemes = [];
      disableMinSize = true;
      plugins = {

      };
    };

    userPlugins = {

    };
  };
}