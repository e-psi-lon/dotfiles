{
  pkgs,
  lib,
  mkComposeInfo,
  cfg,
  autoStart,
  exposePorts,
  ...
}:

let
  name = "redis";

  smallRedis = pkgs.redis.override { withSystemd = false; };

  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";

    contents = with pkgs; [
      smallRedis
      cacert
      tzdata
    ];

    enableFakechroot = true;
    fakeRootCommands = ''
      ${pkgs.dockerTools.shadowSetup}
      groupadd -r redis -g 1000
      useradd -r -g redis -u 1000 -d /data -s /sbin/nologin redis
      mkdir -p /data
      chown -R redis:redis /data
    '';

    config = {
      Entrypoint = [
        (lib.getExe' smallRedis "redis-server")
        "--dir"
        "/data"
        "--maxmemory"
        "400mb" # Leave some overhead for the 512M container limit
        "--maxmemory-policy"
        "allkeys-lru"
      ];
      Cmd = [ ];
      ExposedPorts = {
        "6379/tcp" = { };
      };
      User = "1000:1000";
      Volumes = {
        "/data" = { };
      };
      WorkingDir = "/data";
    };
  };
in
{
  inherit image;

  composeInfo = mkComposeInfo {
    inherit name exposePorts autoStart;
    base = {
      image = "${name}:latest";
      volumes = [ "${cfg.dataDirectory}:/data" ];
      healthcheck = {
        test = [
          "CMD"
          (lib.getExe smallRedis)
          "ping"
        ];
        interval = "10s";
        timeout = "5s";
        retries = 5;
        start_period = "5s";
      };
      deploy.resources.limits = {
        cpus = "0.5";
        memory = "512M";
      };
    };
    ports = [ "6379:6379" ];
  };
}
