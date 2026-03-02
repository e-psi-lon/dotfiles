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

    kernelPackages = pkgs.linuxPackages_6_18;

    tmp = {
      useZram = true;
      zramSettings.zram-size = "30%";
    };
  };
}
