{ config, ... }:
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
      "/persist/var/lib/gokapi"
      "/persist/var/lib/nixos"
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
      "--keep-daily 3"
      "--keep-weekly 1"
      "--keep-monthly 0"
    ];
  };
}
