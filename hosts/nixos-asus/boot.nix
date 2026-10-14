{
  pkgs,
  lib,
  ...
}:

{
  boot = {
    loader = {
      efi.efiSysMountPoint = "/boot/efi";
      grub.minegrub-world-sel = {
        enable = true;
        customIcons = [ ];
      };
    };
    initrd.systemd.tpm2.enable = true;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [
      "asus-armoury"
      "vhost_vsock"
    ];
    supportedFilesystems = {
      ntfs = true;
      ntfs-3g = lib.mkForce false;
    };

    tmp = {
      useZram = true;
      zramSettings.zram-size = "ram * 0.3";
    };
  };
}
