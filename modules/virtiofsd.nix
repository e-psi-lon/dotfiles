{ config, lib, pkgs, ... }:
let
  cfg = config.virtiofsd.users;

  mkVirtiofsd = name:
    let
      u = config.users.users.${name};
      uid = toString u.uid;
      gid = toString config.users.groups.${u.group}.gid;
    in {
      services."virtiofsd-${name}" = {
        description = "virtiofsd for ${name}";
        serviceConfig = {
          Type = "simple";
          ExecStart = lib.concatStringsSep " " [
            (lib.getExe pkgs.virtiofsd)
            "--fd=3"
            "--shared-dir=${u.home}"
            "--sandbox chroot"
            "--translate-uid squash-guest:0:${uid}:4294967295"
            "--translate-gid squash-guest:0:${gid}:4294967295"
          ];
        };
      };

      sockets."virtiofsd-${name}" = {
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = "/run/virtiofsd/${name}.sock";
          SocketMode = "0060";
          SocketGroup = u.group;
        };
      };
    };
in {
  options.virtiofsd.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };

  config = {
    systemd = lib.mkMerge (map mkVirtiofsd cfg);

    assertions = map (name: {
      assertion = config.users.users.${name}.uid != null
        && config.users.groups.${config.users.users.${name}.group}.gid != null;
      message = "virtiofsd: user ${name} needs a pinned uid and group gid.";
    }) cfg;
  };
}