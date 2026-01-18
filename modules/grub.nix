{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.loader = {
    grub = {
      useOSProber = lib.mkDefault true;
      efiSupport = lib.mkDefault true;
      efiInstallAsRemovable = lib.mkDefault true;
      device = lib.mkDefault "nodev";
      configurationLimit = lib.mkDefault 5;
    };

    efi.canTouchEfiVariables = false;
  };
}
