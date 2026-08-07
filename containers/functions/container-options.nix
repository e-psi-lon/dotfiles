{ lib, ... }:
{
  description,
  defaultExpose ? false,
  defaultRestartPolicy ? "unless-stopped",
  containerOptions ? { },
}:
{
  enable = lib.mkEnableOption description;

  exposePorts = lib.mkOption {
    type = lib.types.bool;
    default = defaultExpose;
    description = "Bind container ports to the host.";
  };

  restartPolicy = lib.mkOption {
    type = lib.types.str;
    default = defaultRestartPolicy;
    description = "Restart policy for the container.";
  };

  envFiles = lib.mkOption {
    type = lib.types.listOf lib.types.path;
    default = [ ];
    description = "List of host paths to .env files.";
  };

  volumes = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "List of volume mappings (e.g. ['/var/lib/my-app:/data']).";
  };

  extraPorts = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Additional ports to expose in the format 'hostPort:containerPort' (e.g., ['8080:80']). Only applicable if exposePorts is true.";
  };

  autoStart = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Start automatically with the stack. If false, it's assigned to a manual profile.";
  };

}
// containerOptions
