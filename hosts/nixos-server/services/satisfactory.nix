{ lib, pkgs, ... }:
let
  stateDir = "/var/lib/satisfactory";
in
{
  users = {
    users.satisfactory = {
      isSystemUser = true;
      group = "satisfactory";
      home = stateDir;
    };
    groups.satisfactory = {};
  };

  networking.firewall = {
    allowedTCPPorts = [ 7777 8888 ];
    allowedUDPPorts = [ 7777 ];
  };

  systemd.services.satisfactory = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment.HOME = stateDir;
    startLimitIntervalSec = 600; 
    startLimitBurst = 5;
    serviceConfig = {
      User = "satisfactory";
      StateDirectory = "satisfactory";
      WorkingDirectory = stateDir;
      ExecStartPre = "${lib.getExe pkgs.steamcmd} +force_install_dir ${stateDir}/gamefiles +login anonymous +app_update 1690800 validate +quit";
      ExecStart = "${lib.getExe pkgs.steam-run} ${stateDir}/gamefiles/FactoryServer.sh -Port=7777 -ReliablePort=8888";
      KillSignal = "SIGINT";
      TimeoutStartSec = "30min";
      TimeoutStopSec = 120;

      MemoryHigh = "10G";
      MemoryMax = "12G";
      MemorySwapMax = 0;
      OOMPolicy = "stop";
      Restart = "always";
      RestartSec = 15;

      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
    };
  };
}
