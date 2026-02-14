{ lib, ... }:
{
  hardware = {
    nvidia.prime.sync.enable = true;
    nvidia-container-toolkit.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
  };

  users = {
    groups.data = { };
    users.e-psi-lon.extraGroups = lib.mkAfter [ "data"  "kvm" ];
  };

  systemd.tmpfiles.settings."10-data" = {
    "/mnt/data" = {
      d = {
        mode = "0775";
        owner = "root";
        group = "data";
      };
    };
  };
}
