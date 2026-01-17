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

    fail2ban = {
      enable = lib.mkDefault true;
      bantime = lib.mkDefault "10m";
      bantime-increment.enable = lib.mkDefault true;
      maxretry = lib.mkDefault 5;
    };
    openssh = {
      enable = lib.mkDefault true;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        PermitRootLogin = lib.mkDefault "no";
        X11Forwarding = lib.mkDefault true;
        MaxAuthTries = lib.mkDefault 4;
      };
    };
  };
}
