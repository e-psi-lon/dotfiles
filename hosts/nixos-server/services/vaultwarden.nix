{ config, ... }: {

  services = {
    vaultwarden = {
      enable = true;
      domain = "vault.${config.mainInternalDomain}";
      dbBackend = "postgresql";
      configurePostgres = true;
      configureNginx = true;
      config = {}; # TODO: Research the settings for vaultwarden
    };
    nginx.virtualHosts."${config.services.vaultwarden.domain}".useACMEHost = config.mainInternalDomain;
  };
}