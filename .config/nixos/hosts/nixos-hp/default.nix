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

  services.xserver.videoDrivers = [ "intel" ];

  environment = {
    sessionVariables = {
      LIBVA_DRIVER_NAME = "i965";
    };
    enableDebugInfo = false;
  };

  system.stateVersion = "25.05";

}
