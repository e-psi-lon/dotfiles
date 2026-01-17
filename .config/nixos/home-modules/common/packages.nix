{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wget
    fastfetch
    file
    eza
    zip
    unzip
    htop
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
