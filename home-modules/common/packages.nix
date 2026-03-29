{ pkgs, config, ... }:

{
  config.home.packages = with pkgs; [
    wget
    file
    glab
    eza
    zip
    unzip
    (if config.hasNvidiaGpu then pkgs.btop-cuda else pkgs.btop)
    bat
    glow
    ripgrep
    fd
    jq
    dust
    dnsutils
    (github-copilot-cli.overrideAttrs (oldAttrs: {
      postInstall = "";
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
