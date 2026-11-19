{ config, pkgs, ... }:
let
  blackboxConfig = pkgs.writeText "blackbox.yml" ''
    modules:
      http_2xx:
        prober: http
        timeout: 5s
        http:
          preferred_ip_protocol: "ip4"
          valid_status_codes: [200, 301, 302, 403]
      tcp_connect:
        prober: tcp
        timeout: 5s
  '';
in
{
  sops.secrets."grafana/secret-key" = {
    owner = "grafana";
    group = "grafana";
    mode = "0400";
    restartUnits = [ "grafana.service" ];
  };

  services = {
    nginx.statusPage = true;

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3001;
          domain = "grafana.${config.mainInternalDomain}";
          root_url = "https://grafana.${config.mainInternalDomain}/";
        };
        security = {
          disable_gravatar = true;
          secret_key = "$__file{${config.sops.secrets."grafana/secret-key".path}}";
        };
      };
      provision.datasources.settings = {
        datasources = [
          {
            name = "Prometheus";
            uid = "prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://127.0.0.1:9090";
            isDefault = true;
            editable = false;
          }
        ];
      };
    };

    prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9090;
      stateDir = "prometheus";
      retentionTime = "90d";
      extraFlags = [
        "--storage.tsdb.retention.size=20GB"
      ];
      

      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [
            { targets = [ "127.0.0.1:9100" ]; }
          ];
        }
        {
          job_name = "postgres";
          static_configs = [
            { targets = [ "127.0.0.1:9187" ]; }
          ];
        }
        {
          job_name = "redis";
          static_configs = [
            { targets = [ "127.0.0.1:9121" ]; }
          ];
        }
        {
          job_name = "nginx";
          static_configs = [
            { targets = [ "127.0.0.1:9113" ]; }
          ];
        }
        {
          job_name = "restic";
          static_configs = [
            { targets = [ "127.0.0.1:9753" ]; }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            { targets = [ "127.0.0.1:9090" ]; }
          ];
        }
        {
          job_name = "blackbox-http";
          metrics_path = "/probe";
          params.module = [ "http_2xx" ];
          static_configs = [
            {
              targets = [
                "https://files.${config.mainDomain}"
                "https://git.${config.mainDomain}"
                "https://vault.${config.mainDomain}"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:9115";
            }
          ];
        }
      ];

      exporters = {
        node = {
          enable = true;
          listenAddress = "127.0.0.1";
          enabledCollectors = [
            "processes"
            "systemd"
          ];
        };

        postgres = {
          enable = true;
          listenAddress = "127.0.0.1";
          runAsLocalSuperUser = true;
        };

        redis = {
          enable = true;
          listenAddress = "127.0.0.1";
          extraFlags = [
            "--redis.addr=redis://127.0.0.1:6379"
          ];
        };

        nginx = {
          enable = true;
          listenAddress = "127.0.0.1";
          scrapeUri = "http://127.0.0.1/nginx_status";
        };

        restic = {
          enable = true;
          listenAddress = "127.0.0.1";
          repositoryFile = config.sops.secrets."restic/repository".path;
          passwordFile = config.sops.secrets."restic/password".path;
          environmentFile = config.sops.templates."restic-environment".path;
          refreshInterval = 3600;
        };

        blackbox = {
          enable = true;
          listenAddress = "127.0.0.1";
          configFile = blackboxConfig;
        };
      };
    };

    nginx.virtualHosts."grafana.${config.mainInternalDomain}" = {
      useACMEHost = config.mainInternalDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        extraConfig = ''
          allow 100.64.0.0/10;
          allow fd7a:115c:a1e0::/48;
          deny all;
        '';
      };
    };
  };
}
