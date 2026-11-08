{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  rootDevice = config.fileSystems."/".device;
  rootDeviceUnit = "${utils.escapeSystemdPath rootDevice}.device";
  btrfs = lib.getExe pkgs.btrfs-progs;
  mount = lib.getExe' pkgs.util-linux "mount";
  umount = lib.getExe' pkgs.util-linux "umount";
  wipeScript = pkgs.writeShellScript "wipe-root-subvolume" ''
    set -eu

    mountPoint=/run/root-btrfs
    mkdir -p "$mountPoint"
    ${mount} -t btrfs -o subvolid=5 ${lib.escapeShellArg rootDevice} "$mountPoint"
    trap '${umount} "$mountPoint"' EXIT

    if ${btrfs} subvolume show "$mountPoint/root" >/dev/null 2>&1; then
      ${btrfs} subvolume delete --recursive "$mountPoint/root"
      ${btrfs} subvolume sync "$mountPoint"
    fi
    ${btrfs} subvolume create "$mountPoint/root"
    for d in /var/log /var/lib/nixos; do
      mkdir -p "$mountPoint/root$d" "$mountPoint/persist$d"
    done
  '';
in
{
  assertions = [
    {
      assertion = config.fileSystems."/".fsType == "btrfs";
      message = "nixos-server root wipe requires the root filesystem to use Btrfs.";
    }
  ];

  boot.initrd.systemd = {
    storePaths = with pkgs; [ wipeScript util-linux btrfs-progs ];
    initrdBin = [
      pkgs.btrfs-progs
      pkgs.util-linux
    ];

    services.wipe-root-subvolume = {
      description = "Recreate the ephemeral root Btrfs subvolume";
      requiredBy = [ "initrd-root-fs.target" ];
      before = [
        "sysroot.mount"
        "initrd-root-fs.target"
      ];
      requires = [ rootDeviceUnit ];
      after = [ rootDeviceUnit ];
      unitConfig = {
        DefaultDependencies = "no";
        ConditionPathIsMountPoint = "!/sysroot";
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = wipeScript;
      };
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/lib/acme"
      "/var/lib/tailscale"
      "/var/lib/nixos"
      "/var/lib/postgresql"
      "/var/lib/redis"
      "/var/lib/systemd"
      "/var/lib/vaultwarden"
      "/var/lib/prometheus"
      "/var/lib/forgejo"
      "/var/lib/containers"
      "/var/backup/postgresql"
      "/var/log"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
