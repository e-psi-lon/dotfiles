{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wget
    fzf
    fastfetch
    file
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