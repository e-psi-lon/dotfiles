{
  config,
  pkgs,
  ...
}:
let
  url = "files.${config.mainDomain}";
  dataDir = "/var/lib/gokapi/data";
in
{
  sops = {
    secrets = {
      "gokapi/cipher" = { };
      "gokapi/db" = {
        sopsFile = config.paths.secretsDir + "/gokapi-db.server.bin";
        format = "binary";
      };
    };
    templates."gokapi-secrets.json" = {
      content = builtins.toJSON {
        Encryption = {
          Level = 3;
          Cipher = config.sops.placeholder."gokapi/cipher";
          Salt = "";
          Checksum = "";
          ChecksumSalt = "";
        };
      };
      restartUnits = [ "gokapi.service" ];
    };
  };
  services = {
    gokapi = {
      enable = true;
      mutableSettings = false;
      settingsFile = "%d/gokapi-secrets.json";
      settings = {
        Authentication = {
          Method = 0;
          Username = "e-psi-lon";
          OnlyRegisteredUsers = false;
          SaltAdmin = "LUwnGEeEG436NehPpanaxpJ1YvY64j";
          SaltFiles = "ymAkh9IlIoJ0txnZFf51EcrjykCZkK";
        };
        Port = "127.0.0.1:53842";
        ServerUrl = "https://${url}";
        RedirectUrl = "https://${config.mainDomain}";
        PublicName = "Gokapi";
        DataDir = dataDir;
        DatabaseUrl = "sqlite:///${dataDir}/gokapi.sqlite";
        ConfigVersion = 22;
        MaxFileSizeMB = 1024;
        MaxMemory = 50;
        ChunkSize = 45;
        MaxParallelUploads = 3;
        UseSsl = false;
        PicturesAlwaysLocal = false;
        SaveIp = false;
        IncludeFilename = true;
      };
    };

    nginx.virtualHosts."${url}" = {
      useACMEHost = config.mainDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.gokapi.settings.Port}";
        extraConfig = ''
          client_max_body_size 50m;
          proxy_request_buffering off;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
      };
    };
  };
  systemd.services.gokapi.serviceConfig = {
    ExecStartPre =
      let
        gokapiStart = pkgs.writeShellScript "gokapi-start" ''
          db="${dataDir}/gokapi.sqlite"
          if [ ! -e "$db" ]; then
            mkdir -p "$(dirname "$db")"
            cp "$CREDENTIALS_DIRECTORY/gokapi.sqlite" "$db"
            chmod +w "$db"
          fi
        '';
      in
      [ gokapiStart ];
    LoadCredential = [
      "gokapi.sqlite:${config.sops.secrets."gokapi/db".path}"
      "gokapi-secrets.json:${config.sops.templates."gokapi-secrets.json".path}"
    ];
  };
}
