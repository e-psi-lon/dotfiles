{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    mkIf
    mkMerge
    mkDefault
    types
    mapAttrsToList
    filterAttrs
    attrNames
    groupBy
    length
    concatStringsSep
    concatLists
    elemAt
    listToAttrs
    nameValuePair
    ;

  raw = fromTOML (builtins.readFile config.paths.idsToml);
  dynamic = raw.dynamic or { };
  dynamicUsers = dynamic.users or [ ];
  dynamicGroups = dynamic.groups or [ ];
  bands = removeAttrs raw [ "dynamic" ];

  entries = concatLists (
    mapAttrsToList (
      band: b:
      mapAttrsToList (name: id: {
        inherit band name id;
        min = elemAt b.range 0;
        max = elemAt b.range 1;
      }) b.ids
    ) bands
  );

  table = listToAttrs (map (e: nameValuePair e.name e.id) entries);

  show = concatStringsSep ", ";
  dupeKeys =
    key: attrNames (filterAttrs (_: v: length v > 1) (groupBy (e: toString (key e)) entries));
  outOfRange = lib.filter (e: e.id < e.min || e.id > e.max) entries;

  dupes =
    idOf: set:
    let
      withId = filterAttrs (_: x: idOf x != null) set;
      byId = groupBy (n: toString (idOf withId.${n})) (attrNames withId);
    in
    filterAttrs (_: names: length names > 1) byId;

  strictUsers = filterAttrs (n: _: !(lib.elem n dynamicUsers)) config.users.users;
  strictGroups = filterAttrs (n: _: !(lib.elem n dynamicGroups)) config.users.groups;
in
{
  options.users.users = mkOption {
    type = types.attrsOf (
      types.submodule (
        { config, name, ... }: {
          options.deterministicSubUidGidRange = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Derive the subuid/subgid range from `uid`:
              start = 100000 + (uid - 1000) * 65536, count = 65536.
            '';
          };

          config = mkMerge [
            (mkIf (table ? ${name}) { uid = mkDefault table.${name}; })
            (mkIf (config.deterministicSubUidGidRange && config.uid != null) (
              let
                start =
                  if config.uid >= 1000 then
                    100000 + (config.uid - 1000) * 65536
                  else
                    1879048192 + config.uid * 65536;
              in
              {
                subUidRanges = [
                  {
                    startUid = start;
                    count = 65536;
                  }
                ];
                subGidRanges = [
                  {
                    startGid = start;
                    count = 65536;
                  }
                ];
              }
            ))
          ];
        }
      )
    );
  };

  options.users.groups = mkOption {
    type = types.attrsOf (
      types.submodule (
        { name, ... }: { config = mkIf (table ? ${name}) { gid = mkDefault table.${name}; }; }
      )
    );
  };

  config.assertions = [
    {
      assertion = dupeKeys (e: e.name) == [ ];
      message = "ids.toml: name listed in several bands: ${show (dupeKeys (e: e.name))}";
    }
    {
      assertion = dupeKeys (e: e.id) == [ ];
      message = "ids.toml: id used twice: ${show (dupeKeys (e: e.id))}";
    }
    {
      assertion = outOfRange == [ ];
      message = "ids.toml: outside its band: ${show (map (e: "${e.name}=${toString e.id}") outOfRange)}";
    }
    {
      assertion = lib.all (n: !(table ? ${n})) (dynamicUsers ++ dynamicGroups);
      message = "ids.toml: names in both a band and [dynamic]: ${
        show (lib.filter (n: table ? ${n}) (dynamicUsers ++ dynamicGroups))
      }";
    }
  ]
  ++ mapAttrsToList (name: u: {
    assertion = u.uid != null;
    message = "users.users.${name}.uid is not set (add it to a band or [dynamic] in ids.toml).";
  }) strictUsers
  ++ mapAttrsToList (name: g: {
    assertion = g.gid != null;
    message = "users.groups.${name}.gid is not set (add it to a band or [dynamic] in ids.toml).";
  }) strictGroups
  ++ mapAttrsToList (id: names: {
    assertion = false;
    message = "uid ${id} is used by multiple users: ${show names}";
  }) (dupes (u: u.uid) config.users.users)
  ++ mapAttrsToList (id: names: {
    assertion = false;
    message = "gid ${id} is used by multiple groups: ${show names}";
  }) (dupes (g: g.gid) config.users.groups)
  ++ mapAttrsToList (name: u: {
    assertion = u.uid != null && u.uid <= 66533 && !u.autoSubUidGidRange;
    message = ''
      users.users.${name}.deterministicSubUidGidRange requires `uid` to be set
      (<=66533) and `autoSubUidGidRange` to be false.
    '';
  }) (filterAttrs (_: u: u.deterministicSubUidGidRange) config.users.users);
}
