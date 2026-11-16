{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf types mapAttrsToList filterAttrs;
  cfg = config.users.users;
in
{
  options.users.users = mkOption {
    type = types.attrsOf (types.submodule ({ config, ... }: {
      options.deterministicSubUidGidRange = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Derive the subuid/subgid range from `uid`:
          start = 100000 + (uid - 1000) * 65536, count = 65536.
        '';
      };

      config = mkIf (config.deterministicSubUidGidRange && config.uid != null) (
        let
          start = 100000 + (config.uid - 1000) * 65536;
        in
        {
          subUidRanges = [ { startUid = start; count = 65536; } ];
          subGidRanges = [ { startGid = start; count = 65536; } ];
        }
      );
    }));
  };

  config.assertions = mapAttrsToList (name: u: {
    assertion =
      u.uid != null
      && u.uid >= 1000
      && u.uid <= 66533
      && !u.autoSubUidGidRange;
    message = ''
      users.users.${name}.deterministicSubUidGidRange requires `uid` to be set
      (1000..66533) and `autoSubUidGidRange` to be false.
    '';
  }) (filterAttrs (_: u: u.deterministicSubUidGidRange) cfg);
}