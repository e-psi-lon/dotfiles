{ config, ... }:
{
  android-sdk = {
    enable = true;
    path = "${config.xdg.configHome}/android-sdk";
    packages = sdk: with sdk; [
      cmdline-tools-latest
      platform-tools
      build-tools-36-0-0
      emulator
      ndk-29-0-14206865
      platforms-android-36
      sources-android-36
    ];
  };
}