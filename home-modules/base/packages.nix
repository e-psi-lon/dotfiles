{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wget
    file
    ripgrep
    fd
    jq
    dnsutils

    zip
    unzip
    ouch

    eza
    bat
    glow
    dust
  ];
}