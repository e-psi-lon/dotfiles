{ config, lib, pkgs, ... }:
let
  alertScript = pkgs.writeShellApplication {
    name = "restic-failure-alert";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.msmtp
      pkgs.systemd
    ];
    text = ''
      {
        printf 'To: me@${config.mainDomain}\n'
        printf 'Subject: Restic backup failed on %s\n' "$(hostname --fqdn)"
        printf '\n'
        printf 'The Restic backup or repository check failed on %s.\n\n' "$(hostname --fqdn)"
        printf 'Recent service output:\n'
        journalctl --unit=restic-backups-server.service --no-pager --lines=50
      } | msmtp --account=backups --set-from-header=on "me@${config.mainDomain}"
    '';
  };
in
{
  sops.secrets = {
    "restic/access-key" = { };
    "restic/password" = { };
    "restic/repository" = { };
    "restic/secret-key" = { };
  };

  sops.templates."restic-environment".content = ''
    AWS_ACCESS_KEY_ID=${config.sops.placeholder."restic/access-key"}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."restic/secret-key"}
    AWS_DEFAULT_REGION=auto
  '';

  services.restic.backups.server = {
    initialize = true;
    repositoryFile = config.sops.secrets."restic/repository".path;
    passwordFile = config.sops.secrets."restic/password".path;
    environmentFile = config.sops.templates."restic-environment".path;
    paths = [
      "/persist/etc/machine-id"
      "/persist/etc/ssh"
      "/persist/var/backup/postgresql"
      "/persist/var/lib/acme"
      "/persist/var/lib/nixos"
      "/persist/var/lib/private/gokapi"
      "/persist/var/lib/tailscale"
      "/persist/var/lib/vaultwarden"
    ];
    runCheck = true;
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
    pruneOpts = [
      "--keep-last 3"
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 0"
    ];
  };

  systemd.services.restic-backups-server.unitConfig.OnFailure = [ "restic-failure-alert.service" ];

  systemd.services.restic-failure-alert = {
    description = "Send an alert when the Restic backup fails";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe alertScript;
    };
  };
}
