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
  name = "postgres";

  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";
    
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

    config = let
      entrypoint = pkgs.writeShellApplication {
        name = "${name}-entrypoint";
        runtimeInputs = with pkgs; [ postgresql ];
        text = ''
          ${builtins.readFile ./entrypoint.sh}
        '';
      };
    in {
      Entrypoint = [ (lib.getExe entrypoint) ];
      ExposedPorts = { "5432/tcp" = {}; };
      User = "1000:1000";
    };
  };
in {
  inherit image;

  composeInfo = mkComposeInfo {
    inherit name exposePorts autoStart;
    base = {
      image = "${name}:latest";
      shm_size = "128mb";
      volumes = [ 
        "${cfg.dataDirectory}:/var/lib/postgresql/data"
      ];
      deploy.resources.limits = {
        cpus = "0.5";
        memory = "256M";
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
