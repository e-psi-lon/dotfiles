{ config, ... }: {
  sops.secrets = {
    "luks/home.key".sopsFile = "${config.paths.secretsDir}/luks-home.asus.bin";
    "luks/data.key".sopsFile = "${config.paths.secretsDir}/luks-data.asus.bin";
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_2TB_S7HENU0YA05207M";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };

            boot = {
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };

            swap = {
              size = "12G";
              content = {
                type = "luks";
                name = "SWAP";
                settings = {
                  allowDiscards = true;
                  # Reuse the same passphrase as the root partition (builtin behavior of systemd-cryptsetup)
                };
                content = {
                  type = "swap";
                  resumeDevice = true;
                };
              };
            };

            root = {
              size = "256G";
              content = {
                type = "luks";
                name = "ROOT";
                settings = {
                  allowDiscards = true;
                  # Interactive prompt/TPM2
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd:1"
                        "noatime"
                      ];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd:3"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };

            home = {
              size = "128G";
              content = {
                type = "luks";
                name = "HOME";
                settings = {
                  keyFile = config.sops.secrets."luks/home.key".path;
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "btrfs";
                  extraArgs = [ "-f" ];
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd:2"
                    "nofail"
                    "x-systemd.requires-mount-for=/run/secrets"
                  ];
                };
              };
            };

            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "DATA";
                settings = {
                  keyFile = config.sops.secrets."luks/data.key".path;
                  allowDiscards = true;
                };
                content = {
                  type = "filesystem";
                  format = "btrfs";
                  extraArgs = [ "-f" ];
                  mountpoint = "/mnt/data";
                  mountOptions = [
                    "nofail"
                    "x-systemd.requires-mount-for=/run/secrets"
                    "compress=zstd:1"
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
