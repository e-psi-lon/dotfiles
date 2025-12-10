{ config, pkgs, ... }:

{
    imports = [
        /etc/nixos/hardware-configuration.nix
    ];

    
    networking.hostName = "nixos-asus";

    environment = {
        systemPackages = with pkgs; [
            jetbrains-toolbox

        ];
    };

    hardware = {
        graphics.enable = true;
    };
}