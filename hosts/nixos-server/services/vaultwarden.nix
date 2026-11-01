{ config, ... }: {
  sops = {
    secrets = {
      "vaultwarden/admin-token".sopsFile = config.paths.secretsDir + "/vaultwarden.server.yaml";
      "vaultwarden/smtp-password".sopsFile = config.paths.secretsDir + "/vaultwarden.server.yaml";
    };
    templates."vaultwarden-env".content = ''
      ADMIN_TOKEN=${config.sops.placeholder."vaultwarden/admin-token"}
      SMTP_PASSWORD=${config.sops.placeholder."vaultwarden/smtp-password"}
    '';
  };
  services = {
    vaultwarden = {
      enable = true;
      domain = "vault.${config.mainInternalDomain}";
      dbBackend = "postgresql";
      configurePostgres = true;
      configureNginx = true;
      environmentFile = config.sops.templates."vaultwarden-env".path;
      config = {
        SIGNUPS_ALLOWED = false;
        INVITATIONS_ALLOWED = true;
        SMTP_HOST = ""; # TODO: Find a relay
        # SMTP_PORT = ;
        SMTP_SECURITY = "starttls";
        SMTP_FROM = "vault@mail.${config.mainDomain}";
        SMTP_FROM_NAME = "${config.username}'s Vaultwarden";
        SMTP_USERNAME = config.username;
      };
    };
    nginx.virtualHosts."${config.services.vaultwarden.domain}".useACMEHost = config.mainInternalDomain;
  };
}