{
  dockerTools,
  lib,
  jre_minimal,
  cacert,
  mkComposeInfo,
  cfg,
  flakeRev,
  autoStart,
  exposePorts,
  containerUidGid,
  ...
}:

let
  name = "minecraft-server";
  tag = toString flakeRev;
  containerUidGidStr = toString containerUidGid;
  jdk = cfg.jdk;
  headlessJdk = jdk.override {
    headless = true;
    enableGtk = false;
    enableJavaFX = false;
  };
  jre = jre_minimal.override {
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
  streamImage = dockerTools.streamLayeredImage {
    inherit name tag;

    contents = [
      cacert
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
      User = "${containerUidGidStr}:${containerUidGidStr}";
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
