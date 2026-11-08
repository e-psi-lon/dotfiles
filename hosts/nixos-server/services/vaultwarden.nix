{ config, ... }: {
  sops = {
    secrets = {
      "vaultwarden/admin-token" = { };
    };
    templates."vaultwarden-env" = {
      content = ''
        ADMIN_TOKEN='${config.sops.placeholder."vaultwarden/admin-token"}'
        SMTP_PASSWORD=${config.sops.placeholder."mail/smtp-password"}
      '';
      restartUnits = [ "vaultwarden.service" ];
    };
  };
  services = {
    vaultwarden = {
      enable = true;
      domain = "vault.${config.mainDomain}";
      dbBackend = "postgresql";
      configurePostgres = true;
      configureNginx = true;
      environmentFile = config.sops.templates."vaultwarden-env".path;
      config = {
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = true;
        INVITATIONS_ALLOWED = true;
        SMTP_HOST = config.mailing.host;
        SMTP_PORT = config.mailing.port;
        SMTP_SECURITY = "starttls";
        SMTP_FROM = "vaultwarden@${config.mailing.domain}";
        SMTP_FROM_NAME = "${config.username}'s Vaultwarden";
        SMTP_USERNAME = config.mailing.username;
      };
    };
    nginx.virtualHosts."${config.services.vaultwarden.domain}" = {
      useACMEHost = config.mainDomain;
      locations."^~ /admin".proxyPass = "http://vaultwarden/nonexistent";
    };
  };
}
