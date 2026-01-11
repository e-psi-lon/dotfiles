{ lib, ... }:
{
    hardware = {
      nvidia.prime = {
        sync.enable = true;
        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
      };
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
    groups.data = {};
    users.e-psi-lon.extraGroups = lib.mkAfter [ "data" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/data 0775 root data - -"
  ];

}