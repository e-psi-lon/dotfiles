{ config, ... }: {

  services = {
    vaultwarden = {
      enable = true;
      domain = "vault.${config.mainInternalDomain}";
      dbBackend = "postgresql";
      backupDir = "/var/backup/vaultwarden";
      configurePostgres = true;
    };
    nginx.virtualHosts."${config.services.vaultwarden.domain}".useACMEHost = config.mainInternalDomain;
  };
}