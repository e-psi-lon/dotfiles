{ config, lib, pkgs, ... }:
let
  domain = "git.${config.mainDomain}";
  sshPort = 2222;
  localAddress = "${config.services.forgejo.settings.server.HTTP_ADDR}:${toString config.services.forgejo.settings.server.HTTP_PORT}";
in
{
  sops.secrets."forgejo-runner/token" = { };
  services = {
    openssh = {
      ports = [ sshPort ];
      extraConfig = ''
        Match LocalPort ${toString sshPort}
          AllowUsers ${config.services.forgejo.user}
          AuthenticationMethods publickey
          AllowTcpForwarding no
          AllowAgentForwarding no
          X11Forwarding no
          PermitTTY no
      '';
    };
    forgejo = {
      enable = true;
      database = {
        type = "postgres";
        createDatabase = true;
      };
      lfs.enable = true;

      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = 3000;
          SSH_PORT = sshPort;
          SSH_DOMAIN = domain;
          DISABLE_SSH = false;
        };
        service.DISABLE_REGISTRATION = true;
        session.COOKIE_SECURE = true;
        actions.ENABLED = true;

        mailer = {
          ENABLED = true;
          PROTOCOL = "smtp+starttls";
          SMTP_ADDR = config.mailing.host;
          SMTP_PORT = config.mailing.port;
          USER = config.mailing.username;
          FROM = "Forgejo <forgejo@${config.mailing.domain}>";
        };
      };

      secrets.mailer.PASSWD = config.sops.secrets."mail/smtp-password".path;
    };
    nginx = {
      upstreams.forgejo.servers."${localAddress}" = { };
      virtualHosts.${domain} = {
        useACMEHost = config.mainDomain;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://forgejo";
            extraConfig = ''
              client_max_body_size 150m;
            '';
          };
          "^~ /api/actions/".proxyPass = "http://forgejo/api/nonexistent/";
        };
      };
    };
    forgejo-runner.instances.main = {
      enable = true;
      settings = {
        runner.labels = [ "docker:docker://node:current" ];
        server.connections.default = {
          url = "http://${localAddress}";
          uuid = "38666264-3364-3135-3630-653631363136";
        };
      };
      secrets.server.connections.default.token_url =
        config.sops.secrets."forgejo-runner/token".path;
    };
  };
  networking.firewall.allowedTCPPorts = [ sshPort ];
  
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "forgejo-admin" ''
      exec sudo -u ${config.services.forgejo.user} env \
        FORGEJO_WORK_DIR=${config.services.forgejo.stateDir} \
        FORGEJO_CUSTOM=${config.services.forgejo.customDir} \
        ${lib.getExe config.services.forgejo.package} "$@"
    '')
  ];
}