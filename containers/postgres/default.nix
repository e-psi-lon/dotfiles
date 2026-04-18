{
  pkgs,
  lib,
  mkComposeInfo,
  flakeRev,
  cfg,
  autoStart,
  exposePorts,
  ...
}:

let
  name = "postgres";
  tag = toString flakeRev;

  streamImage = pkgs.dockerTools.streamLayeredImage {
    inherit name tag;
    
    contents = with pkgs; [
      postgresql
      cacert
      tzdata
    ];

    enableFakechroot = true;
    fakeRootCommands = ''
      ${pkgs.dockerTools.shadowSetup}
      groupadd -r postgres -g 1000
      useradd -r -g postgres -u 1000 -d /var/lib/postgresql -s /sbin/nologin postgres
      mkdir -p /var/lib/postgresql/data /run/postgresql
      chown -R postgres:postgres /var/lib/postgresql /run/postgresql
    '';

    config =
      let
        entrypoint = pkgs.writeShellApplication {
          name = "${name}-entrypoint";
          runtimeInputs = with pkgs; [ postgresql ];
          text = ''
            ${builtins.readFile ./entrypoint.sh}
          '';
        };
      in
      {
        Entrypoint = [ (lib.getExe entrypoint) ];
        ExposedPorts = {
          "5432/tcp" = { };
        };
        User = "1000:1000";
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
      image = "${streamImage.imageName}:${streamImage.imageTag}";
      shm_size = "128mb";
      volumes = [ "${cfg.dataDirectory}:/var/lib/postgresql/data" ];
      deploy.resources.limits = {
        cpus = "0.5";
        memory = "256M";
      };
      healthcheck = {
        test = [
          "CMD"
          (lib.getExe' pkgs.postgresql "pg_isready")
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
      userns_mode = "keep-id";
      secrets = [
        {
          source = "postgres-password";
          uid = "1000";
          mode = "0440";
        }
      ];
    };
    ports = [ "5432:5432" ];
  };
}
