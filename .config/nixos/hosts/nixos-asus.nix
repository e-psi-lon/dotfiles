{ config, pkgs, lib, ... }:

{
    environment = {
        systemPackages = with pkgs; [
            jetbrains-toolbox
            bat
            glow
            ripgrep
            fd
            jq
            dust
        ];
    };

    users = {
        groups.data = {};
        users.e-psi-lon.extraGroups = lib.mkAfter [ "data" ];
    };

    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    systemd.tmpfiles.rules = [
        "d /mnt/data 0775 root data - -"
    ];


    hardware.nvidia.prime = {
        sync.enable = true;

        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
    };

    nix = {
        optimise.automatic = true;

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
        };
    };


    system.stateVersion = "25.11";
}
