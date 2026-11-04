{ config, ... }: {
  sops = {
    secrets = {
      "vaultwarden/admin-token" = { };
      "vaultwarden/smtp-password" = { };
    };
    templates."vaultwarden-env".content = ''
      ADMIN_TOKEN='${config.sops.placeholder."vaultwarden/admin-token"}'
      SMTP_PASSWORD=${config.sops.placeholder."vaultwarden/smtp-password"}
    '';
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
        SMTP_HOST = "smtp-relay.brevo.com";
        SMTP_PORT = 587;
        SMTP_SECURITY = "starttls";
        SMTP_FROM = "vaultwarden@mail.${config.mainDomain}";
        SMTP_FROM_NAME = "${config.username}'s Vaultwarden";
        SMTP_USERNAME = "c12c44001@smtp-brevo.com";
      };
    };
    nginx.virtualHosts."${config.services.vaultwarden.domain}" = {
      useACMEHost = config.mainDomain;
      locations."/admin".return = "404";
    };
  };
}
