{
  lib,
  config,
  mkBindMountWithOptions,
  username,
  ...
}:
{
  specialisation.battery-saver = lib.mkIf config.hardware.nvidia.primeBatterySaverSpecialisation {
    configuration.hardware.nvidia.prime.sync.enable = lib.mkForce false;
  };
  fileSystems = {
    "/home/${username}/Dev" = mkBindMountWithOptions "/mnt/data/Dev" [ 
      "noauto" 
      "x-systemd.wanted-by=multi-user.target"
      "x-systemd.requires=mnt-data.mount"
      "x-systemd.after=mnt-data.mount" 
    ];
    "/home/${username}/.local/share/containers" = mkBindMountWithOptions "/mnt/data/containers" [ 
      "noauto" 
      "x-systemd.wanted-by=multi-user.target"
      "x-systemd.requires=mnt-data.mount"
      "x-systemd.after=mnt-data.mount" 
    ];
  };

  hardware = {
    nvidia.prime.sync.enable = lib.mkOverride 900 true;
    nvidia.prime.offload.enable = lib.mkOverride 900 false;
    nvidia.primeBatterySaverSpecialisation = false; # Setting to true will create a specialisation that disable the GPU entirely
    nvidia-container-toolkit.enable = true;
    enableRedistributableFirmware = true;

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
    users.${username}.extraGroups = [
      "data"
      "kvm"
    ];
  };

  systemd.tmpfiles.settings."10-data" = {
    "/mnt/data" = {
      d = {
        mode = "0775";
        user = "root";
        group = "data";
      };
    };
  };

}
