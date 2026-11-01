{ config, lib, modulesPath, ... }: {

  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./services
    ./networking.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options = {
    mainDomain = lib.mkOption {
      type = lib.types.str;
    };
    mainInternalDomain = lib.mkOption {
      type = lib.types.str;
      default = "int.${config.mainDomain}";
    };
  };

  config = {
    boot = {
      kernelParams = [
        "console=ttyAMA0"
      ];
      tmp = {
        useZram = true;
        zramSettings.zram-size = "ram * 0.25";
      };
      loader.limine.secureBoot.enable = false;
    };
    mainDomain = "e-psi-lon.dev";
    documentation.enable = false;

      nix = {
        optimise.automatic = true;
        settings.trusted-users = [
          "root"
          config.username
        ];

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
        };
      };

    system.stateVersion = "26.11";
  };
  
}