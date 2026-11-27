{ pkgs, lib, ... }:

let
  serversRoot = "/var/lib/mc-servers"; # Each subfolder is a self-contained server
  activeLink = "/var/lib/mc-profiles/current"; # Symlink updated by the script

  java-version = pkgs.writeShellApplication {
    name = "java-version";
    text = ''
      case "''${1:-}" in
        8)  shift; exec ${lib.getExe pkgs.jre8} "$@" ;;
        17) shift; exec ${lib.getExe pkgs.jdk17} "$@" ;;
        25) shift; exec ${lib.getExe pkgs.jdk25} "$@" ;;
        *) echo "Usage: java-version {8|17|25} [args...]" >&2
          exit 1 ;;
      esac
    '';
  };

  selectServer = pkgs.writeShellApplication {
    name = "mc-select";
    runtimeInputs = with pkgs; [ fzf coreutils systemd findutils ];
    text = ''
      SERVERS_ROOT="${serversRoot}"
      ACTIVE_LINK="${activeLink}"
      ${builtins.readFile ./mc-select.sh}
    '';
  };
in
{
  environment.systemPackages = [ selectServer java-version pkgs.dtach ];
  users = {
    users.minecraft = {
      isSystemUser = true;
      group = "minecraft";
      home = "/var/lib/mc-profiles";
    };
    groups.minecraft = {};
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];

  systemd.services.mc-server = {
    description = "Minecraft Server";
    after = [ "network.target" ];
    path = with pkgs; [ dtach bash java-version  ];

    serviceConfig = {
      User = "minecraft";
      Group = "minecraft";
      WorkingDirectory = activeLink;
      ExecStart = "${lib.getExe pkgs.dtach} -N /run/mc-server/console.sock ${activeLink}/run.sh";
      StateDirectory = [ "mc-profiles" "mc-servers" ];
      StateDirectoryMode = "0750";
      RuntimeDirectory = "mc-server";
      RuntimeDirectoryMode = "0750";
      Restart = "on-failure";
      RestartSec = 5;
      KillSignal = "SIGINT";
      TimeoutStopSec = 60;
      # Enable when systemd 263 gets released
      # StandardInput = "broker-log";
      # StandardOutput = "inherit";
      # StandardError = "inherit";
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      PrivateUsers = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      RestrictSUIDSGID = true;
      RestrictNamespaces = true;
      SystemCallArchitectures = "native";
      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
      LockPersonality = true;
      RestrictRealtime = true;
    };
  };
}