{ config, ... }: {
  services = {
    prometheus = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9090;
      storage = {
        path = "/var/lib/prometheus";
      };
      stateDir = "prometheus";
      exporters.node = {
        enable = true;
        listenAddress = "0.0.0.0";
        enabledCollectors = [ "systemd" ];
      };
    };
    nginx.virtualHosts."prometheus.${config.mainInternalDomain}" = {
      useACMEHost = config.mainInternalDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        extraConfig = ''
          allow 100.64.0.0/10;
          allow fd7a:115c:a1e0::/48;
          deny all;
        '';
      };
    };
  };
}
