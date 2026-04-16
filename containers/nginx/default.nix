{ 
  pkgs,
  lib, 
  mkComposeInfo,
  cfg,
  autoStart,
  ...
}:

let
  name = "nginx";

  healthPort = 43417;
  
  hasSsl = cfg.sslCert != null && cfg.sslKey != null;

  nginxConf = pkgs.writeTextDir "etc/nginx/nginx.conf" ''
    user nginx nginx;
    worker_processes auto;
    error_log stderr warn;
    pid /var/run/nginx.pid;

    events {
      worker_connections 1024;
    }

    http {
      include ${pkgs.nginx}/conf/mime.types;
      default_type application/octet-stream;
      
      # Route all temp paths to our disposable tmpfs arrays
      client_body_temp_path /var/cache/nginx/client_body;
      proxy_temp_path /var/cache/nginx/proxy;
      fastcgi_temp_path /var/cache/nginx/fastcgi;
      uwsgi_temp_path /var/cache/nginx/uwsgi;
      scgi_temp_path /var/cache/nginx/scgi;
      
      access_log /dev/stdout;
      
      sendfile on;
      keepalive_timeout 65;

      server {
        listen ${toString healthPort};
        server_name localhost;

        location /health {
          access_log off;
          add_header Content-Type text/plain;
          return 200 "OK";
        }
      }

      ${cfg.serverBlocks}

      include /etc/nginx/conf.d/*.conf;
    }
  '';

  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";
    
    contents = with pkgs; [ 
      nginx 
      tzdata
      curl
      cacert
      nginxConf
    ];

    enableFakechroot = true;
    fakeRootCommands = ''
      ${pkgs.dockerTools.shadowSetup}
      groupadd -r nginx -g 1000
      useradd -r -g nginx -u 1000 -d /var/empty -s /bin/sh nginx
      groupadd -r nogroup -g 65534
      useradd -r -g nogroup -u 65534 -d /nonexistent -s /bin/false nobody
      mkdir -p /var/cache/nginx
      chown -R nginx:nginx /var/cache/nginx
    '';

    config = {
      Entrypoint = [ 
        (lib.getExe pkgs.nginx)
        "-e" "stderr"
        "-c" "/etc/nginx/nginx.conf"
        "-g" "daemon off;"
      ];
      ExposedPorts = { 
        "80/tcp" = {};
        "443/tcp" = {};
        "${toString healthPort}/tcp" = {};
      };
      WorkingDir = "/";
    };
  };
in {
  inherit image;

  composeInfo = mkComposeInfo {
    inherit name autoStart;
    exposePorts = true;
    base = {
      image = "${name}:latest";
      volumes = [ "${cfg.extraConfigDir}:/etc/nginx/conf.d:ro" ]
        ++ lib.optional hasSsl "${cfg.sslCert}:/etc/nginx/ssl/cert.pem:ro"
        ++ lib.optional hasSsl "${cfg.sslKey}:/etc/nginx/ssl/key.pem:ro";
      tmpfs = [
        "/var/cache/nginx"
        "/var/run"
      ];
      healthcheck = {
        test = [ "CMD" (lib.getExe pkgs.curl) "-f" "http://localhost:${toString healthPort}/health" ];
        interval = "30s";
        timeout = "10s";
        retries = 3;
      };
    };
    ports = [ 
      "50080:80"
    ] ++ lib.optional hasSsl "50443:443";
  };
}