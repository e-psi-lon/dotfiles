{ config, pkgs, ... }:

{
    boot.loader = {
        grub = {
            minegrub-world-sel = {
                enable = true;
            };

            useOSProber = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "nodev";
            configurationLimit = 5;
        };

        efi.canTouchEfiVariables = false;
    };
}
