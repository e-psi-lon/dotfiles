{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wget
    file
    glab
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
    github-copilot-cli

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
