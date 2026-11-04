{ lib, ... }:
{
  virtualisation = {
    vmVariant = {
      virtualisation.sharedDirectories.ssh-host-keys = {
        source = "/home/e-psi-lon/dotfiles/staging/extra/persist/etc/ssh";
        target = "/run/future-host-ssh";
      };

      sops.age.sshKeyPaths = lib.mkForce [
        "/run/future-host-ssh/ssh_host_ed25519_key"
      ];
    };
    vmVariantWithDisko = {
      disko.devices.disk.main = {
        device = lib.mkForce "/dev/vda";
        imageSize = "30G";
      };
      fileSystems."/persist".neededForBoot = lib.mkForce true;
    };
  };
}
