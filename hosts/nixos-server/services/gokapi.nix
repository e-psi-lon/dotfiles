{ config, ...}: 
let
  url = "files.${config.mainDomain}"; 
in
{
  services = {
    gokapi = {
      enable = true;
      mutableSettings = false;
      settings = {
        Port = "127.0.0.1:53842";
        ServerUrl = "https://${url}";
        RedirectUrl = "https://${config.mainDomain}";
        PublicName = "Gokapi";
        UseSsl = false;
        LengthId = 15;
        MaxFileSizeMB = 102400;
        MaxMemory = 50;
        ChunkSize = 45;
        MaxParallelUploads = 3;
        
      };
    };

    nginx.virtualHosts."${url}" = {
      useACMEHost = config.mainDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.gokapi.settings.Port}";
        extraConfig = ''
          client_max_body_size 100m;
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };
  };
}