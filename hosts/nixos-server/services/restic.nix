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
    paths = [ "/persist" ];
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
