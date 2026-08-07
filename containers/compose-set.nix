{
  lib,
  containers,
  evaluatedContainers,
  enabledContainers,
}:
{
  services =
    let
      base = lib.mapAttrs (
        name: c: c.composeInfo // { image = "${c.streamImage.imageName}:${c.streamImage.imageTag}"; }
      ) evaluatedContainers;
    in
    base
    // lib.optionalAttrs containers.nginx.enable {
      nginx = base.nginx // {
        depends_on =
          let
            hiddenEnabled = lib.filterAttrs (
              name: _: name != "nginx" && !(containers.${name}.exposePorts) && containers.${name}.autoStart
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
      c = containers.${name};
    in
    acc // (if meta ? secrets then meta.secrets c else { })
  ) { } enabledContainers;
}
