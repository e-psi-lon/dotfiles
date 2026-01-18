{ config, ... }:

{
  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  nix.settings = {
    substituters = [
      "https://cache.nixos-cuda.org"
    ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
