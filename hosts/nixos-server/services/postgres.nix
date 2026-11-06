{ pkgs, ... }: {
  services = {
    postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
    };
    postgresqlBackup = {
      enable = true;
      backupAll = true;
      compression = "none";  # Better for restic, which already compresses 
      location = "/var/backup/postgresql";
    };
  };
}
