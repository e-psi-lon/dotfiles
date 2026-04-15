{ 
  pkgs,
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
  };
  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";
    
    contents = [ 
      pkgs.cacert 
    ];

    config = {
      Entrypoint = [ "${proxyBin}/bin/${name}" ];
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
      restart = "always";
      deploy.resources.limits.memory = "32M";
    };
    ports = [ "5050:8080" ];
  };
}
