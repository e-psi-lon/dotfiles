{ pkgs, ... }:

{
  boot = {
    loader = {
      efi.efiSysMountPoint = "/boot/efi";
      grub.minegrub-world-sel = {
        enable = true;
        customIcons = [ ];
      };
    };

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "asus-armoury" ];

    tmp = {
      useZram = true;
      zramSettings.zram-size = "ram * 0.3";
    };
  };
}
