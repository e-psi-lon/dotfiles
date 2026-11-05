{
  config,
  lib,
  ...
}:
{
  options.mailing = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "mail.${config.mainDomain}";
    };
    host = lib.mkOption {
      type = lib.types.str;
    };
    port = lib.mkOption {
      type = lib.types.port;
    };
    username = lib.mkOption {
      type = lib.types.str;
    };
    accounts = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.from = lib.mkOption {
            type = lib.types.str;
          };
        }
      );
      default = { };
    };
  };

  config = {
    mailing = {
      host = "smtp-relay.brevo.com";
      port = 587;
      username = "c12c44001@smtp-brevo.com";
      accounts.backups.from = "backups@${config.mailing.domain}";
    };

    sops.secrets."mail/smtp-password" = { };

    programs.msmtp = {
      enable = true;
      accounts = lib.mapAttrs (
        _: account:
        {
          host = config.mailing.host;
          port = config.mailing.port;
          auth = true;
          tls = true;
          tls_starttls = true;
          user = config.mailing.username;
          passwordeval = "cat ${config.sops.secrets."mail/smtp-password".path}";
        }
        // account
      ) config.mailing.accounts;
    };
  };
}
