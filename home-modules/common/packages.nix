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
    (github-copilot-cli.overrideAttrs (oldAttrs: {
      postInstall = ''
      '';
    })) # TODO: Remove once the PR make it from master to unstable

    # Development
    uv
    python3
    gcc
    cmake
    gnumake
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
