{

  imports = [
    ./hardware-configuration.nix
    ./optimization.nix
  ];

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 2;
    };

    blacklistedKernelModules = [ "intel-spi" ];
  };

  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  programs.mtr.enable = true;

  services.xserver.videoDrivers = [ "intel" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="22d9", ATTRS{idProduct}=="2769", MODE="0666"
  '';

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };
    enableDebugInfo = false;
  };

  system.stateVersion = "25.05";

}
