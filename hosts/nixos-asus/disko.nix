{ config, lib, ... }: 
let 
  nonInitrdLuksDevices = [
    "home"
    "data"
  ];

  luksInfo = partName: {
    inherit
      (config.disko.devices.disk.main.content.partitions.${partName}.content)
      name
      device
      ;
    keyFile = config.disko.devices.disk.main.content.partitions.${partName}.content.settings.keyFile;
  };

  devices = map luksInfo nonInitrdLuksDevices;

  crypttabLine = d: "${d.name} ${d.device} ${d.keyFile} luks\n";
in
{
  sops.secrets = {
    "luks/home.key" = {
      sopsFile = "${config.paths.secretsDir}/luks/home.asus.bin";
      format = "binary";
    };
    "luks/data.key" = {
      sopsFile = "${config.paths.secretsDir}/luks/data.asus.bin";
      format = "binary";
    };
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
              priority = 1;
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
              priority = 2;
              size = "1G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };

            swap = {
              priority = 3;
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
              priority = 4;
              size = "256G";
              content = {
                type = "luks";
                name = "ROOT";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [ "tpm2-device=auto" ];
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
              priority = 5;
              size = "128G";
              content = {
                type = "luks";
                name = "HOME";
                initrdUnlock = false;
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
                    "x-systemd.before=display-manager.service"
                  ];
                };
              };
            };

            data = {
              priority = 6;
              size = "100%";
              content = {
                type = "luks";
                name = "DATA";
                initrdUnlock = false;
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

  environment.etc."crypttab".text = lib.concatMapStrings crypttabLine devices;

  systemd.services = lib.listToAttrs (
    map (d: {
      name = "systemd-cryptsetup@${d.name}";
      value = {
        after = [ "sops-install-secrets.service" ];
        requires = [ "sops-install-secrets.service" ];
      };
    }) devices
  );

}
