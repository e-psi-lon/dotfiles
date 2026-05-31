{ pkgs, lib, ... }:

{
  systemd.services."virtiofsd@" = {
    description = "virtiofsd for %i";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.virtiofsd} --fd=3 --shared-dir=/home/%i --sandbox chroot";
    };
  };

  systemd.sockets."virtiofsd@" = {
    socketConfig = {
      ListenStream = "/run/virtiofsd/%i.sock";
      SocketMode = "0060";
      RuntimeDirectory = "virtiofsd";
      SocketGroup = "%i";
    };
  };
}
