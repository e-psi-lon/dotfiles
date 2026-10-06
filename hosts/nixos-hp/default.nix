{ config, ... }: {

  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./optimization.nix
  ];

  boot = {
    loader.limine = {
      maxGenerations = 2;
      secureBoot.autoEnrollKeys.extraArgs = [ ];
    };

    blacklistedKernelModules = [ "intel-spi" ];
  };
  users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
    home-hp # Trust itself
    home-asus
  ];

  hardware = {
    graphics.enable = true;
    enableRedistributableFirmware = true;
  };

  programs.mtr.enable = true;
  services = {
    xserver.videoDrivers = [ "modesetting" ];
    udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="22d9", ATTRS{idProduct}=="2769", MODE="0666"
    '';
  };

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };
    enableDebugInfo = false;
  };

  system.stateVersion = "26.05";

}
