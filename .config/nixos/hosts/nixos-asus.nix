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
            vesktop
            bash
            pciutils

            # JDKs
            jdk8
            jdk11
            jdk21
            jdk25
        ];
    };
    hardware = {
        nvidia.prime = {
            sync.enable = true;
            amdgpuBusId = "PCI:6:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
        bluetooth = {
            enable = true;
            powerOnBoot = true;
            settings = {
                General = {
                    Experimental = true;
                };
                Policy = {
                    AutoEnable = true;
                };
            };
        };
    };

    boot.loader.efi.efiSysMountPoint = "/boot/efi";

    users = {
        groups.data = {};
        users.e-psi-lon.extraGroups = lib.mkAfter [ "data" ];
    };

    systemd.tmpfiles.rules = [
        "d /mnt/data 0775 root data - -"
    ];

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
