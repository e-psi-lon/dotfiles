{
  config,
  lib,
  pkgs,
  osConfig,
  flakeRev,
  ...
}:

{
  options.podman-containers =
    let
      mkContainerOpts =
        {
          description,
          defaultExpose ? false,
          defaultRestartPolicy ? "unless-stopped",
        }:
        {
          enable = lib.mkEnableOption description;

          exposePorts = lib.mkOption {
            type = lib.types.bool;
            default = defaultExpose;
            description = "Bind container ports to the host.";
          };

          restartPolicy = lib.mkOption {
            type = lib.types.str;
            default = defaultRestartPolicy;
            description = "Restart policy for the container.";
          };

          envFiles = lib.mkOption {
            type = lib.types.listOf lib.types.path;
            default = [ ];
            description = "List of host paths to .env files.";
          };

          volumes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "List of volume mappings (e.g. ['/var/lib/my-app:/data']).";
          };

          extraPorts = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Additional ports to expose in the format 'hostPort:containerPort' (e.g., ['8080:80']). Only applicable if exposePorts is true.";
          };

          autoStart = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Start automatically with the stack. If false, it's assigned to a manual profile.";
          };
        };
      nginxEnabled = config.podman-containers.nginx.enable;
    in
    {
      enable = lib.mkEnableOption "custom podman compose user service for local containers";

      nginx =
        mkContainerOpts {
          description = "nginx proxy container managing routing between services";
          defaultExpose = true;
          defaultRestartPolicy = "always";
        }
        // {
          domain = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Primary domain for the Nginx proxy.";
          };

          httpConfig = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Extra declarative Nginx http {} context configuration.";
          };

          streamConfig = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Extra declarative Nginx stream {} context configuration.";
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

          extraHttpDirectory = lib.mkOption {
            type = lib.types.path;
            default = config.xdg.configHome + "/containers/nginx/http.d";
            description = "Path to a host directory containing extra Nginx HTTP config files (e.g., for additional server blocks).";
          };

          extraStreamDirectory = lib.mkOption {
            type = lib.types.path;
            default = config.xdg.configHome + "/containers/nginx/stream.d";
            description = "Path to a host directory containing extra Nginx Stream config files (e.g., for TCP/UDP services).";
          };
        };

      bypass-cors = mkContainerOpts {
        description = "CORS bypass tool";
        defaultExpose = !nginxEnabled;
        defaultRestartPolicy = "unless-stopped";
      };

      minecraft-server =
        mkContainerOpts {
          description = "Minecraft server";
          defaultExpose = true; # Minecraft and Nginx won't work great together
          defaultRestartPolicy = "unless-stopped";
        }
        // {
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
            default = [ ];
            description = "Additional JVM arguments for the Minecraft server.";
          };
        };

      postgres =
        mkContainerOpts {
          description = "PostgreSQL database server";
          defaultExpose = !nginxEnabled;
          defaultRestartPolicy = "always";
        }
        // {
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

      redis =
        mkContainerOpts {
          description = "redis container";
          defaultExpose = !nginxEnabled;
          defaultRestartPolicy = "unless-stopped";
        }
        // {
          dataDirectory = lib.mkOption {
            type = lib.types.path;
            default = config.xdg.dataHome + "/containers/redis";
            description = "Host directory to store Redis data.";
          };
        };
    };

  config =
    let
      containerDefs = {
        nginx = {
          extraDirs = c: [
            c.extraHttpDirectory
            c.extraStreamDirectory
          ];
        };
        bypass-cors = { };
        minecraft-server = {
          extraDirs = c: [ c.serverDirectory ];
        };
        postgres = {
          extraDirs = c: [ c.dataDirectory ];
          secrets = c: {
            postgres-password = {
              file = c.postgresPasswordPath;
            };
          };
        };
        redis = {
          extraDirs = c: [ c.dataDirectory ];
        };
      };

      enabledContainers = lib.filterAttrs (
        name: _: config.podman-containers.${name}.enable
      ) containerDefs;

      mkComposeInfo =
        {
          name,
          base,
          exposePorts,
          restartPolicy,
          autoStart,
          ports ? [ ],
          envFiles ? [ ],
          volumes ? [ ],
          extraPorts ? [ ],
          secrets ? [ ],
        }:
        base
        // {
          restart = restartPolicy;
        }
        // {
          volumes = (base.volumes or [ ]) ++ volumes;
        }
        // lib.optionalAttrs ((base.env_file or [ ]) ++ envFiles != [ ]) {
          env_file = (base.env_file or [ ]) ++ envFiles;
        }
        // lib.optionalAttrs ((base.secrets or [ ]) ++ secrets != [ ]) {
          secrets = (base.secrets or [ ]) ++ secrets;
        }
        // lib.optionalAttrs exposePorts { ports = (base.ports or [ ]) ++ ports ++ extraPorts; }
        // lib.optionalAttrs (!autoStart) {
          profiles = [ "manual-${name}" ];
          restart = "no";
        };

      # Helper to evaluate container configurations without repetition
      evalContainer =
        name:
        let
          containerCfg = config.podman-containers.${name};
        in
        pkgs.callPackage (./. + "/${name}") {
          mkComposeInfo =
            args:
            mkComposeInfo (
              args
              // {
                inherit (containerCfg)
                  restartPolicy
                  envFiles
                  volumes
                  extraPorts
                  ;
              }
            );
          cfg = containerCfg;
          inherit flakeRev;
          inherit (containerCfg) exposePorts autoStart;
        };

      evaluatedContainers = lib.mapAttrs (name: _: evalContainer name) enabledContainers;

      composeSet = with config.podman-containers; {
        services =
          let
            base = lib.mapAttrs (name: c: c.composeInfo // {
              image = "${c.streamImage.imageName}:${c.streamImage.imageTag}";
            }) evaluatedContainers;
          in
          base
          // lib.optionalAttrs nginx.enable {
            nginx = base.nginx // {
              depends_on =
                let
                  hiddenEnabled = lib.filterAttrs (
                    name: _:
                    name != "nginx"
                    && !(config.podman-containers.${name}.exposePorts)
                    && config.podman-containers.${name}.autoStart
                  ) enabledContainers;
                  withHealth = lib.filterAttrs (
                    n: c: (evaluatedContainers.${n}.composeInfo.healthcheck or null) != null
                  ) hiddenEnabled;
                  withoutHealth = lib.filterAttrs (
                    n: c: (evaluatedContainers.${n}.composeInfo.healthcheck or null) == null
                  ) hiddenEnabled;
                in
                (lib.mapAttrs (name: _: { condition = "service_healthy"; }) withHealth)
                // (lib.mapAttrs (name: _: { condition = "service_started"; }) withoutHealth);
            };
          };

        secrets = lib.foldlAttrs (
          acc: name: meta:
          let
            c = config.podman-containers.${name};
          in
          acc // (if meta ? secrets then meta.secrets c else { })
        ) { } enabledContainers;
      };

      enabledImages = lib.flatten (lib.mapAttrsToList (name: c: c.streamImage) evaluatedContainers);

      composeFile = pkgs.runCommand "compose" {
        nativeBuildInputs = [ pkgs.remarshal ];
        closureInfo = pkgs.closureInfo { rootPaths = enabledImages; };
        json = builtins.toJSON composeSet;
        manifest = builtins.toJSON (map (img: {
          name = img.imageName;
          tag = img.imageTag;
          path = img;
        }) enabledImages);
        passAsFile = [ "json" "manifest" ];
      } ''
        mkdir -p $out
        json2yaml "$jsonPath" > $out/podman-compose.yml
        cp "$manifestPath" $out/images.json
      '';


      directoriesToCreate = lib.flatten (
        lib.mapAttrsToList (
          name: meta:
          let
            c = config.podman-containers.${name};
          in
          if meta ? extraDirs then meta.extraDirs c else [ ]
        ) enabledContainers
      );

      loadImagesScript =
        let
          loadImageBase = ./load-images.sh;
        in
        pkgs.writeShellApplication {
          name = "load-podman-images";
          runtimeInputs = [ pkgs.podman ];
          text = ''
            # Ensure all host volume directories exist with current user ownership
            ${lib.concatMapStringsSep "\n" (dir: "mkdir -p \"${dir}\"") directoriesToCreate}

            images=(${lib.concatMapStringsSep " " (img: "\"${img}\"") enabledImages})
            image_refs=(${lib.concatMapStringsSep " " (img: "\"localhost/${img.imageName}:${img.imageTag}\"") enabledImages})
            ${builtins.readFile loadImageBase}
          '';
        };

      podmanContainerCLI = pkgs.writeShellApplication {
        name = "podman-container";
        runtimeInputs = with pkgs; [
          podman
          podman-compose
        ];
        text = ''
          export COMPOSE_FILE="${composeFile}/podman-compose.yml"
          export PROJECT_NAME="podman-containers"
          ${builtins.readFile ./podman-container.sh}
        '';
      };

    in
    lib.mkIf config.podman-containers.enable {
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
          After = [
            "podman.socket"
            "network.target"
          ];
        };

        Service = {
          Type = "simple";
          ExecStartPre = "${lib.getExe loadImagesScript}";
          Environment = [
            "PODMAN_COMPOSE_PROVIDER=${lib.getExe pkgs.podman-compose}"
            "PODMAN_COMPOSE_WARNING_LOGS=false"
          ];
          ExecStart = "${lib.getExe pkgs.podman} compose -p podman-containers -f ${composeFile}/podman-compose.yml up";
          ExecStop = "${lib.getExe pkgs.podman} compose -p podman-containers -f ${composeFile}/podman-compose.yml down";
          Restart = "on-failure";
          RestartSec = "10";
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
