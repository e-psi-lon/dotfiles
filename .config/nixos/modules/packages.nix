{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    # CLI Tools
    wget
    git
    fzf
    fastfetch
    atuin
    gh
    eza
    stow
    nano
    rsync
    curl
    zip
    unzip
    htop
    tree
    zoxide
    oh-my-posh

    # Development
    neovim
    uv
    python3
    php
    gcc
    nasm

    # Media
    ffmpeg

    # GUI Applications
    firefox
    libreoffice-qt
    prismlauncher

    # Network
    networkmanager
    waypipe
    openvpn
    vscode
  ]);
}
