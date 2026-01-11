{ config, pkgs, ... }:

{
  home.username = "e-psi-lon";
  home.homeDirectory = "/home/e-psi-lon";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    wget
    fzf
    fastfetch
    atuin
    gh
    eza
    zip
    unzip
    htop
    zoxide
    oh-my-posh
    bat
    glow
    ripgrep
    fd
    jq
    dust
    dnsutils

    # Development
    neovim
    uv
    python3
    gcc
    nasm

    # Media
    ffmpeg
    vlc

    # Network
    networkmanager
    waypipe
    openvpn
  ];
}