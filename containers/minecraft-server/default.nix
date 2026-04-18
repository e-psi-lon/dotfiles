{
  pkgs,
  lib,
  mkComposeInfo,
  cfg,
  flakeRev,
  autoStart,
  exposePorts,
  ...
}:

let
  name = "minecraft-server";
  tag = toString flakeRev;
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
  streamImage = pkgs.dockerTools.streamLayeredImage {
    inherit name tag;

    contents = [
      pkgs.cacert
      jre
    ];

    config = {
      Entrypoint = [
        (lib.getExe jre)
      ]
      ++ cfg.javaArgs
      ++ [
        "-XX:MaxRAMPercentage=75.0"
        "-jar"
        "/minecraft/server.jar"
        "nogui"
      ];
      ExposedPorts = {
        "25565/tcp" = { };
      };
      User = "1000:1000";
      Volumes = {
        "/minecraft" = { };
      };
      WorkingDir = "/minecraft";
    };
  };
in
{
  inherit streamImage;

  composeInfo = mkComposeInfo {
    inherit name autoStart exposePorts;
    base = {
      deploy.resources.limits.memory = cfg.memoryLimit;
      volumes = [ "${cfg.serverDirectory}:/minecraft" ];
    };
    ports = [ "25565:25565" ];
  };
}
