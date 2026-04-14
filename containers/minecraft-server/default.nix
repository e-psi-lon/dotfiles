{ 
  pkgs,
  lib, 
  mkComposeInfo,
  cfg,
  autoStart,
  exposePorts,
  ...
}:

let
  name = "minecraft-server";
  javaVersion = toString cfg.javaVersion;
  jdk = pkgs."jdk${javaVersion}";
  headlessJdk = jdk.override {
      headless = true;
      enableGtk = false;
      enableJavaFX = false;
  };
  jre = pkgs."jre${javaVersion}_minimal".override {
      jdk = headlessJdk;
      jdkOnBuild = headlessJdk;
      modules = [ 
        "java.base" 
        "java.logging" 
        "java.naming" 
        "java.xml" 
        "jdk.crypto.ec"
        "java.desktop"
        "java.management"
        "jdk.management"
        "jdk.unsupported"
        "java.sql"
        "java.instrument"
      ];
  };
  image = pkgs.dockerTools.streamLayeredImage {
    name = name;
    tag = "latest";
    
    contents = [ 
      pkgs.cacert 
      jre
    ];

    config = {
      Entrypoint = [ 
        (lib.getExe jre) 
      ] ++ cfg.javaArgs ++ [ 
        "-XX:MaxRAMPercentage=75.0"
        "-jar" 
        "/minecraft/server.jar"
        "nogui"
      ];
      ExposedPorts = { "25565/tcp" = {}; };
      User = "1000:1000";
      WorkingDir = "/minecraft";
      Volumes = {
        "/minecraft" = {};
      };
    };
  };
in {
  inherit image;

  composeInfo = mkComposeInfo {
    inherit name autoStart exposePorts;
    base = {
      image = "${name}:latest";
      restart = "no";
      deploy.resources.limits.memory = cfg.memoryLimit;
      volumes = [
        "${cfg.serverDirectory}:/minecraft"
      ] ++ cfg.volumes;
    };
    ports = [ "25565:25565" ];
  };
}
