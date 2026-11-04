{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    enabledCollectors = [ "systemd" ];
  };
}
