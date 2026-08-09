{
  dockerTools,
  lib,
  postgresql,
  cacert,
  tzdata,
  writeShellApplication,
  mkComposeInfo,
  flakeRev,
  cfg,
  autoStart,
  exposePorts,
  containerUidGid,
  ...
}:

let
  name = "postgres";
  tag = toString flakeRev;
  containerUidGidStr = toString containerUidGid;

  streamImage = dockerTools.streamLayeredImage {
    inherit name tag;

    contents = [
      postgresql
      cacert
      tzdata
    ];

    enableFakechroot = true;
    fakeRootCommands = ''
      ${dockerTools.shadowSetup}
      groupadd -r postgres -g ${containerUidGidStr}
      useradd -r -g postgres -u ${containerUidGidStr} -d /var/lib/postgresql -s /sbin/nologin postgres
      mkdir -p /var/lib/postgresql/data /run/postgresql
      chown -R postgres:postgres /var/lib/postgresql /run/postgresql
    '';

    config =
      let
        entrypoint = writeShellApplication {
          name = "${name}-entrypoint";
          runtimeInputs = [ postgresql ];
          text = ''
            ${builtins.readFile ./entrypoint.sh}
          '';
        };
      in
      {
        Entrypoint = [ (lib.getExe entrypoint) ];
        StopSignal = "SIGINT";
        ExposedPorts = {
          "5432/tcp" = { };
        };
        User = "${containerUidGidStr}:${containerUidGidStr}";
        Volumes = {
          "/var/lib/postgresql/data" = { };
        };
        WorkingDir = "/var/lib/postgresql";
      };
  };
in
{
  inherit streamImage;

  composeInfo = mkComposeInfo {
    inherit name exposePorts autoStart;
    base = {
      shm_size = "128mb";
      volumes = [ "${cfg.dataDirectory}:/var/lib/postgresql/data" ];
      deploy.resources.limits = {
        cpus = "0.5";
        memory = "256M";
      };
      healthcheck = {
        test = [
          "CMD"
          (lib.getExe' postgresql "pg_isready")
          "-h"
          "localhost"
          "-p"
          "5432"
          "-U"
          "postgres"
        ];
        interval = "10s";
        timeout = "5s";
        retries = 10;
        start_period = "5s";
      };
      secrets = [
        {
          source = "postgres-password";
          uid = containerUidGid;
          mode = "0400";
        }
      ];
    };
    ports = [ "5432:5432" ];
  };
}
