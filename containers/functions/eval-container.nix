{
  pkgs,
  config,
  flakeRev,
  mkComposeInfo,
  containerUidGid,
  ...
}:
name:
let
  containerCfg = config.podman-containers.${name};
in
pkgs.callPackage (../definitions + "/${name}") {
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
  inherit flakeRev containerUidGid;
  inherit (containerCfg) exposePorts autoStart;
}
