{
  lib,
  dockerTools,
  redis,
  cacert,
  tzdata,
  mkComposeInfo,
  cfg,
  autoStart,
  exposePorts,
  flakeRev,
  containerUidGid,
  ...
}:

let
  name = "redis";
  tag = toString flakeRev;
  containerUidGidStr = toString containerUidGid;

  smallRedis = (redis.override { withSystemd = false; }).overrideAttrs { doCheck = false; };
  streamImage = dockerTools.streamLayeredImage {
    inherit name tag;

    contents = [
      cacert
      tzdata
    ];

    enableFakechroot = true;
    fakeRootCommands = ''
      ${dockerTools.shadowSetup}
      groupadd -r redis -g ${containerUidGidStr}
      useradd -r -g redis -u ${containerUidGidStr} -d /data -s /sbin/nologin redis
      mkdir -p /data
      chown -R redis:redis /data
    '';

    config = {
      Entrypoint = [
        (lib.getExe' smallRedis smallRedis.serverBin)
        "--dir"
        "/data"
        "--maxmemory"
        "400mb" # Leave some overhead for the 512M container limit
        "--maxmemory-policy"
        "allkeys-lru"
      ];
      Cmd = [ ];
      ExposedPorts."6379/tcp" = { };
      User = "${containerUidGidStr}:${containerUidGidStr}";
      Volumes."/data" = { };
      WorkingDir = "/data";
    };
  };
in
{
  inherit streamImage;

  composeInfo = mkComposeInfo {
    inherit name exposePorts autoStart;
    base = {
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
      userns_mode = "keep-id";
      deploy.resources.limits = {
        cpus = "0.5";
        memory = "512M";
      };
    };
    ports = [ "6379:6379" ];
  };
}
