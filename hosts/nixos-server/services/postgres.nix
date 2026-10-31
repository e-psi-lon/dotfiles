{ pkgs, ... }: {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
    };
    postgresqlBackup = {
      enable = true;
      backupAll = true;
      location = "/var/backup/postgresql";
    };
  };
}