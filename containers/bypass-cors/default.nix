{ 
  pkgs,
  lib,
  mkComposeInfo,
  exposePorts,
  autoStart,
  ...
}:

let
  name = "bypass-cors";
  proxyBin = pkgs.buildGoModule {
    pname = name;
    version = "1.0.0";
    src = ./.; 
    vendorHash = null; # We only use the standard library, so no vendor hash is needed
    env = {
      CGO_ENABLED = 0;
    };
    ldflags = [ "-s" "-w" ];
    meta = {
      description = "A simple CORS proxy server to bypass CORS restrictions in development.";
      mainProgram = name;
    };
  };
  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";
    
    contents = [ 
      pkgs.cacert 
    ];

    config = {
      Entrypoint = [ (lib.getExe proxyBin) ];
      ExposedPorts = { "8080/tcp" = {}; };
      User = "1000:1000";
      WorkingDir = "/";
    };
  };
in {
  inherit image;

  composeInfo = mkComposeInfo {
    inherit name exposePorts autoStart;
    base = {
      image = "${name}:latest";
      deploy.resources.limits = {
        cpus = "0.1";
        memory = "32M";
      };
    };
    ports = [ "5050:8080" ];
  };
}
