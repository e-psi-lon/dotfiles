{ config, ... }:
{

  imports = [
    ./hardware-configuration.nix
    ./optimization.nix
  ];

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        configurationLimit = 2;
      };
    };

    blacklistedKernelModules = [ "intel-spi" ];
  };
  users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
    home-hp # Trust itself
    home-asus 
  ];

  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  programs.mtr.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="22d9", ATTRS{idProduct}=="2769", MODE="0666"
  '';

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };
    enableDebugInfo = false;
  };

  users.mutableUsers = false;

  system.stateVersion = "26.05";

}
