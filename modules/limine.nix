{ lib, ... }:
{
  boot.loader = {
    limine = {
      enable = true;

      maxGenerations = lib.mkDefault 5;

      secureBoot = {
        enable = lib.mkDefault true;
        autoGenerateKeys = lib.mkDefault true;
        autoEnrollKeys.enable = lib.mkDefault true;
      };
    };

    efi.canTouchEfiVariables = true;
  };
}
