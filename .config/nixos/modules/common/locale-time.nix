{ lib, ... }:

{
  time.timeZone = lib.mkDefault "Europe/Paris";

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = lib.mkDefault "fr_FR.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "fr_FR.UTF-8";
    LC_MEASUREMENT = lib.mkDefault "fr_FR.UTF-8";
    LC_MONETARY = lib.mkDefault "fr_FR.UTF-8";
    LC_NAME = lib.mkDefault "fr_FR.UTF-8";
    LC_NUMERIC = lib.mkDefault "fr_FR.UTF-8";
    LC_PAPER = lib.mkDefault "fr_FR.UTF-8";
    LC_TELEPHONE = lib.mkDefault "fr_FR.UTF-8";
    LC_TIME = lib.mkDefault "fr_FR.UTF-8";
  };

  console.keyMap = lib.mkDefault "fr";

  services.xserver.xkb = {
    layout = lib.mkDefault "fr";
    variant = lib.mkDefault "";
  };
}
