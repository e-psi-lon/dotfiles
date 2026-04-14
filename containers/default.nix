{ config, lib, pkgs, osConfig, ... }:

{
  options.podman-containers = let
    mkContainerOpts = { description, defaultExpose ? false }: {
      enable = lib.mkEnableOption description;
      
      exposePorts = lib.mkOption {
        type = lib.types.bool;
        default = defaultExpose;
        description = "Bind container ports to the host.";
      };
      
      envFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = "List of host paths to .env files.";
      };

      volumes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of volume mappings (e.g. ['/var/lib/my-app:/data']).";
      };

      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Start automatically with the stack. If false, it's assigned to a manual profile.";
      };
    };
    nginxEnabled = config.podman-containers.nginx.enable;
  in {
    enable = lib.mkEnableOption "custom podman compose user service for local containers";

    nginx = mkContainerOpts { 
      description = "nginx proxy container managing routing between services"; 
      defaultExpose = true;
    } // {
      domain = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "Primary domain for the Nginx proxy.";
      };

      serverBlocks = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Extra declarative Nginx server blocks to inject into the http {} context.";
      };
      
      sslCert = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to the host SSL certificate (e.g., from sops-nix).";
      };

      sslKey = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to the host SSL key (e.g., from sops-nix).";
      };

      extraConfigDir = lib.mkOption {
        type = lib.types.path;
        default = config.xdg.configHome + "/containers/nginx/conf.d";
        description = "Path to a host directory containing extra Nginx config files to include (e.g., for additional server blocks or custom settings).";
      };
    };

    bypass-cors = mkContainerOpts { 
      description = "CORS bypass tool"; 
      defaultExpose = !nginxEnabled;
    };

    minecraft-server = mkContainerOpts { 
      description = "Minecraft server"; 
      defaultExpose = true; # Minecraft and Nginx won't work great together
    } // {
      serverDirectory = lib.mkOption {
        type = lib.types.path;
        default = config.xdg.dataHome + "/containers/minecraft-server";
        description = "Host directory to store the Minecraft world and server properties.";
      };
      
      memoryLimit = lib.mkOption {
        type = lib.types.str;
        default = "4G";
        description = "Maximum RAM allocated to the Minecraft server.";
      };

      javaVersion = lib.mkOption {
        type = lib.types.int;
        default = 21;
        description = "Java version to run the Minecraft server with.";
      };

      javaArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Additional JVM arguments for the Minecraft server.";
      };
    };

    postgres = mkContainerOpts { 
      description = "PostgreSQL database server"; 
      defaultExpose = true;
    } // {
      dataDirectory = lib.mkOption {
        type = lib.types.path;
        default = config.xdg.dataHome + "/containers/postgres";
        description = "Host directory to store PostgreSQL data.";
      };
      
      postgresPasswordPath = lib.mkOption {
        type = lib.types.str;
        default = config.xdg.dataHome + "/containers/postgres-password";
        description = "Path to the file containing the password for the default 'postgres' user.";
      };
    };

    redis = mkContainerOpts { 
      description = "redis container"; 
      defaultExpose = !nginxEnabled;
    } // {
      dataDirectory = lib.mkOption {
        type = lib.types.path;
        default = config.xdg.dataHome + "/containers/redis";
        description = "Host directory to store Redis data.";
      };
    };
  };

  config = let
    yaml = pkgs.formats.yaml { };

    mkComposeInfo = { name, base, exposePorts, autoStart, ports }: 
      base
      // lib.optionalAttrs exposePorts { inherit ports; }
      // lib.optionalAttrs (!autoStart) {
        profiles = [ "manual-${name}" ];
        restart = "no";
      };
    
    # Helper to evaluate container configurations without repetition
    evalContainer = name: pkgs.callPackage (./. + "/${name}") {
      inherit mkComposeInfo;
      cfg = config.podman-containers.${name};
      exposePorts = config.podman-containers.${name}.exposePorts;
      autoStart = config.podman-containers.${name}.autoStart;
    };

    nginxContainer = evalContainer "nginx";
    bypassCorsContainer = evalContainer "bypass-cors";
    minecraftServerContainer = evalContainer "minecraft-server";

    docker-compose = {
      version = "3.8";
      services = {}
        // lib.optionalAttrs config.podman-containers.nginx.enable {
          nginx = nginxContainer.composeInfo;
        }
        // lib.optionalAttrs config.podman-containers.bypass-cors.enable {
          bypass-cors = bypassCorsContainer.composeInfo;
        }
        // lib.optionalAttrs config.podman-containers.minecraft-server.enable {
          minecraft-server = minecraftServerContainer.composeInfo;
        };
    };
    composeFile = yaml.generate "docker-compose.yml" docker-compose;

    enabledImages = lib.flatten [
      (lib.optionals config.podman-containers.nginx.enable [ nginxContainer.image ])
      (lib.optionals config.podman-containers.bypass-cors.enable [ bypassCorsContainer.image ])
      (lib.optionals config.podman-containers.minecraft-server.enable [ minecraftServerContainer.image ])
    ];

    loadImagesScript = 
      let
        loadImageBase = ./load-images.sh;
      in pkgs.writeShellApplication {
        name = "load-podman-images";
        runtimeInputs = [ pkgs.podman ];
        text = ''
          images=(${lib.concatMapStringsSep " " (img: "\"${img}\"") enabledImages})
          ${builtins.readFile loadImageBase}
        '';
      };

    podmanContainerCLI = pkgs.writeShellApplication {
      name = "podman-container";
      runtimeInputs = [ pkgs.podman-compose pkgs.podman ];
      text = ''
        export COMPOSE_FILE="${composeFile}"
        export PROJECT_NAME="podman-containers"
        ${builtins.readFile ./podman-container.sh}
      '';
    };

    
  in lib.mkIf config.podman-containers.enable {
      home.packages = [ podmanContainerCLI ];

      assertions = [
        {
          assertion = osConfig.virtualisation.podman.enable or false;
          message = "podman-containers requires 'virtualisation.podman.enable = true' to be set in your NixOS host configuration.";
        }
      ];
      systemd.user.services.podman-containers = {
        
        Unit = {
          Description = "A set of local containers managed all together with podman-compose";
          Requires = [ "podman.socket" ];
          After = [ "podman.socket" "network.target" ];
        };

        Service = {
          Type = "simple";
          ExecStartPre = "${lib.getExe loadImagesScript}";
          ExecStart = "${lib.getExe pkgs.podman-compose} -p podman-containers -f ${composeFile} up";
          ExecStop = "${lib.getExe pkgs.podman-compose} -p podman-containers -f ${composeFile} down";
          Restart = "on-failure";
          RestartSec = "10";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
  };
}