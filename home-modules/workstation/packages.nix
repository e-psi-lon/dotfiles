{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Media
    vlc

    # Tooling
    github-copilot-cli

    # Networking
    networkmanager
    waypipe
    openvpn
  ];
}
