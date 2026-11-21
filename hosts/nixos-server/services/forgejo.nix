{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "git.${config.mainDomain}";
  sshPort = 2222;
  localAddress = "${config.services.forgejo.settings.server.HTTP_ADDR}:${toString config.services.forgejo.settings.server.HTTP_PORT}";
in
{
  sops.secrets."forgejo-runner/token".restartUnits = [
    "forgejo-runner-main.service"
  ];

  users.users.forgejo-runner-main = {
    isSystemUser = true;
    home = "/var/lib/forgejo-runner-main";
    group = "forgejo-runner-main";
    deterministicSubUidGidRange = true;
    linger = true;
  };
  users.groups.forgejo-runner-main = {};
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
        container = {
          docker_host = "unix:///run/user/${toString config.users.users.forgejo-runner-main.uid}/podman/podman.sock";
          valid_volumes = [ "/run/user/${toString config.users.users.forgejo-runner-main.uid}/podman/podman.sock" ];
        };
        runner.labels = [ "docker:docker://node:current" ];
        server.connections.default = {
          url = "http://${localAddress}";
          uuid = "38666264-3364-3135-3630-653631363136";
        };
      };
      secrets.server.connections.default.token_url = config.sops.secrets."forgejo-runner/token".path;
    };
  };
  systemd = {
    user.sockets.podman.wantedBy = [ "sockets.target" ];
    services.forgejo-runner-main = {
      after = [ "forgejo.service" "user@${toString config.users.users.forgejo-runner-main.uid}.service" ];
      wants = [ "forgejo.service" "user@${toString config.users.users.forgejo-runner-main.uid}.service" ];
      environment.DOCKER_HOST = "unix:///run/user/${toString config.users.users.forgejo-runner-main.uid}/podman/podman.sock";
      serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "forgejo-runner-main";
      SupplementaryGroups = lib.mkForce [ ];

      # hardening that doesn't conflict with the socket
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      RestrictNamespaces = true;
      LockPersonality = true;
    };
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
