{ lib, ... }:

{

  services = {
    pipewire = {
      enable = lib.mkDefault true;
      alsa = {
        enable = lib.mkDefault true;
        support32Bit = lib.mkDefault true;
      };
      pulse.enable = lib.mkDefault true;
    };

    flatpak.enable = lib.mkDefault true;
  };
}