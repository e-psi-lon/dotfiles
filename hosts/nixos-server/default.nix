{ config, lib, ... }: {
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
    imports = [
      ./hardware-configuration.nix
      ./disko.nix
      ./services
    ];
    boot = {
      tmp = {
        useZram = true;
        zramSettings.zram-size = "ram * 0.25";
      };
      loader.limine.secureBoot.enable = false;
    };
    mainDomain = "e-psi-lon.dev";
  };
  
}