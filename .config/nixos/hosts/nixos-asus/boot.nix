{
  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub.minegrub-world-sel = {
      enable = true;
      customIcons = [];
   };
  };
}