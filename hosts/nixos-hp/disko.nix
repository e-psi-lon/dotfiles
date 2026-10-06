{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/temp-id";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "256M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };

            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "luks";
                name = "ROOT";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
                  # Interactive prompt/TPM2
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                    "commit=60"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
