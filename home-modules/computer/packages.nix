{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    (if config.hasNvidiaGpu then btop-cuda else btop)
    uv
    python3
    gcc
    cmake
    gnumake
    nasm

    glab
    github-copilot-cli

    ffmpeg
  ];
}