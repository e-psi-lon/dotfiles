{ config, lib, pkgs, ... }:
{
  systemd.user.services.ssh-add-self = {
    Unit = {
      Description = "Load SSH key into agent";
      After = [ "ssh-agent.service" ];
      Requires = [ "ssh-agent.service" ];
      ConditionPathExists = config.selfKeyPrivPath;
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent";
      ExecStart = "${lib.getExe' pkgs.openssh "ssh-add"} ${config.selfKeyPrivPath}";
    };
    Install.WantedBy = [ "default.target" ];
  };
}