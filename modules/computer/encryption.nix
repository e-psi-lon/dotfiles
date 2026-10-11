{ config, lib, pkgs, ... }:
let
  pcrs = config.tpmUnlockPcrs;
  enrollDevices = lib.filterAttrs
    (_: d: lib.elem "tpm2-device=auto" d.crypttabExtraOpts)
    config.boot.initrd.luks.devices;
in  
{

  config = lib.mkIf (pcrs != null) {
    security.tpm2.enable = true;

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "tpm-enroll";
        runtimeInputs = [ pkgs.cryptsetup config.systemd.package ];
        text = lib.concatStringsSep "\n" (lib.mapAttrsToList (name: d: ''
          echo "== ${name} =="
          systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto \
            --tpm2-pcrs=${pcrs} ${lib.escapeShellArg d.device}
        '') enrollDevices);
      })
    ];
  };
}