{
  config,
  lib,
  pkgs,
  osConfig ? null,
  flakeRev ? "unknown-rev",
  ...
}:

{
  options.podman-containers =
    let
      mkContainerOpts = import ./functions/container-options.nix { inherit lib; };
      nginxEnabled = config.podman-containers.nginx.enable;
    in
    {
      enable = lib.mkEnableOption "custom podman compose user service for local containers";
      containerUidGid = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "UID and GID for the user running inside containers. This is a temporary option that'll later be replaced with a more flexible approach of giving each container its own option.";
      };

      nginx = mkContainerOpts {
        description = "nginx proxy container managing routing between services";
        defaultExpose = true;
        defaultRestartPolicy = "always";
        containerOptions = {
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

          sslCerts = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                options = {
                  cert = lib.mkOption { type = lib.types.path; };
                  key = lib.mkOption { type = lib.types.path; };
                };
              }
            );
            default = { };
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
      };
      bypass-cors = mkContainerOpts {
        description = "CORS bypass tool";
        defaultExpose = !nginxEnabled;
        defaultRestartPolicy = "unless-stopped";
      };

      minecraft-server = mkContainerOpts {
        description = "Minecraft server";
        defaultExpose = !nginxEnabled;
        defaultRestartPolicy = "unless-stopped";
        containerOptions = {
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

          jdk = lib.mkOption {
            type = lib.types.package;
            default = pkgs.jdk21;
            description = "Java version to run the Minecraft server with.";
          };

          javaArgs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Additional JVM arguments for the Minecraft server.";
          };
        };
      };

      postgres = mkContainerOpts {
        description = "PostgreSQL database server";
        defaultExpose = !nginxEnabled;
        defaultRestartPolicy = "always";
        containerOptions = {
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
      };

      redis = mkContainerOpts {
        description = "redis container";
        defaultExpose = !nginxEnabled;
        defaultRestartPolicy = "unless-stopped";
        containerOptions = {
          dataDirectory = lib.mkOption {
            type = lib.types.path;
            default = config.xdg.dataHome + "/containers/redis";
            description = "Host directory to store Redis data.";
          };
        };
      };
    };

  config =
    let
      containerDefs = import ./definitions;

      enabledContainers = lib.filterAttrs (
        name: _: config.podman-containers.${name}.enable
      ) containerDefs;

      mkComposeInfo = import ./functions/compose-info.nix { inherit lib; };
      containerUidGid = config.podman-containers.containerUidGid;

      # Helper to evaluate container configurations without repetition
      evalContainer = import ./functions/eval-container.nix {
        inherit
          flakeRev
          pkgs
          config
          mkComposeInfo
          containerUidGid
          ;
      };

      evaluatedContainers = lib.mapAttrs (name: _: evalContainer name) enabledContainers;
      composeSet = import ./compose-set.nix {
        inherit lib evaluatedContainers enabledContainers;
        containers = config.podman-containers;
      };

      enabledImages = lib.flatten (lib.mapAttrsToList (name: c: c.streamImage) evaluatedContainers);

      composeFile = pkgs.callPackage ./pkgs/compose.nix { inherit enabledImages composeSet; };

      directoriesToCreate = lib.flatten (
        lib.mapAttrsToList (
          name: meta:
          let
            c = config.podman-containers.${name};
          in
          (if meta ? sharedDirs then meta.sharedDirs c else [ ])
          ++ (if meta ? dataDirs then meta.dataDirs c else [ ])
        ) enabledContainers
      );

      sharedDirs = lib.flatten (
        lib.mapAttrsToList (
          name: meta:
          let
            c = config.podman-containers.${name};
          in
          if meta ? sharedDirs then meta.sharedDirs c else [ ]
        ) enabledContainers
      );

      loadImagesScript = pkgs.callPackage ./pkgs/load-images {
        inherit directoriesToCreate sharedDirs enabledImages containerUidGid;
      };

      podmanContainerCLI = pkgs.callPackage ./pkgs/podman-container { inherit composeFile; };
      hasSecrets = config.sops.secrets != { };

    in
    lib.mkIf config.podman-containers.enable {
      home.packages = [ podmanContainerCLI ];

      assertions = [
        {
          assertion = osConfig.virtualisation.podman.enable or false;
          message = "podman-containers requires 'virtualisation.podman.enable = true' to be set in your NixOS host configuration.";
        }
      ];
      sops.age.plugins = lib.mkIf hasSecrets (
        [ 
          { type = "derivation"; outPath = "/run/wrappers"; }
        ]
        ++ lib.optional (pkgs.stdenv.isLinux && osConfig == null) { type = "derivation"; outPath = "/usr"; }
      );
      systemd.user.services = {
        podman-containers = {
          Unit =
            let
              hasSecrets = config.sops.secrets != { };
            in
            {
              Description = "A set of local containers managed all together with podman-compose";

              Requires = [ "podman.socket" ] ++ lib.optional hasSecrets "podman-secrets-chown.service";
              After = [
                "podman.socket"
                "network.target"
              ]
              ++ lib.optional hasSecrets "podman-secrets-chown.service";
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

          Install.WantedBy = [ "default.target" ];
        };
      }
      // lib.optionalAttrs hasSecrets {
        sops-nix = {
          Unit = {
            OnSuccess = [ "podman-secrets-chown.service" ];
            OnFailure = [ "podman-secrets-failed-chown.service" ];
          };
          Service.ExecStartPre = [
            "${lib.getExe pkgs.bash} -c 'if [ -d \"${config.sops.defaultSymlinkPath}/containers\" ]; then exec ${lib.getExe pkgs.podman} unshare ${lib.getExe' pkgs.coreutils "chown"} -R 0:0 \"${config.sops.defaultSymlinkPath}/containers\"; fi'"
          ];
        };

        podman-secrets-chown = {
          Unit.Description = "Fix ownership of sops-nix secrets for rootless podman";
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.podman} unshare ${lib.getExe' pkgs.coreutils "chown"} -R ${toString containerUidGid}:${toString containerUidGid} ${config.sops.defaultSymlinkPath}/containers";
          };
        };
        podman-secrets-failed-chown = {
          Unit.Description = "Fix ownership of sops-nix secrets for rootless podman when sops-nix fails to run";
          Service = {
            Type = "oneshot";
            ExecStart = "${lib.getExe pkgs.podman} unshare ${lib.getExe' pkgs.coreutils "chown"} -R 0:0 ${config.sops.defaultSymlinkPath}/containers";
          };
        };
      };
    };
}
