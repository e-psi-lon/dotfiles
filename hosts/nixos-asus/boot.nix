{ pkgs, config, ... }:

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
    extraModulePackages = [
      config.boot.kernelPackages.hid-nintendolic
    ];
    kernelModules = [ "asus-armoury" "hid-nintendolic" "vhost_vsock" ];

    tmp = {
      useZram = true;
      zramSettings.zram-size = "ram * 0.3";
    };
  };
}
