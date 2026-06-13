{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Media
    vlc

    # Networking
    networkmanager
    waypipe
    openvpn
  ];
}