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

    tmp = {
      useZram = true;
      zramSettings.zram-size = "30%";
    };
  };
}
