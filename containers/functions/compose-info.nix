{ lib, ... }:
{
  name,
  base,
  exposePorts,
  restartPolicy,
  autoStart,
  ports ? [ ],
  envFiles ? [ ],
  volumes ? [ ],
  extraPorts ? [ ],
  secrets ? [ ],
}:
base
// {
  restart = restartPolicy;
}
// {
  volumes = (base.volumes or [ ]) ++ volumes;
}
// lib.optionalAttrs ((base.env_file or [ ]) ++ envFiles != [ ]) {
  env_file = (base.env_file or [ ]) ++ envFiles;
}
// lib.optionalAttrs ((base.secrets or [ ]) ++ secrets != [ ]) {
  secrets = (base.secrets or [ ]) ++ secrets;
}
// lib.optionalAttrs exposePorts { ports = (base.ports or [ ]) ++ ports ++ extraPorts; }
// lib.optionalAttrs (!autoStart) {
  profiles = [ "manual-${name}" ];
  restart = "no";
}
