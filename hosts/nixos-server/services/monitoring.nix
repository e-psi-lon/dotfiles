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
  services = {
    nginx.statusPage = true;

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
  };
}
