{ config, pkgs, zen-browser, spicetify-nix, ... }:

{

  imports = [
    ../home-modules/common.nix
    ../home-modules/spicetify.nix
  ];


  home.packages = with pkgs; [
    zen-browser.packages.${stdenv.hostPlatform.system}.default
    vscodew
    ungoogled-chromium # Required for some APIs Firefox doesn't support...
    libreoffice-qt
    prismlauncher
  ];
}