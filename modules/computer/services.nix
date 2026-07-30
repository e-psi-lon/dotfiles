{ lib, config, ... }:

{
  services = {
    fail2ban = {
      enable = lib.mkDefault true;
      bantime = lib.mkDefault "10m";
      bantime-increment.enable = lib.mkDefault true;
      maxretry = lib.mkDefault 5;
    };
    openssh = {
      enable = lib.mkDefault true;
      openFirewall = !config.services.tailscale.enable;
      settings = {
        PasswordAuthentication = lib.mkDefault false;
        PermitRootLogin = lib.mkDefault "no";
        X11Forwarding = lib.mkDefault true;
        MaxAuthTries = lib.mkDefault 3;
        MaxSessions = lib.mkDefault 2;

      };
    };
  };
  networking.firewall.interfaces = lib.mkIf config.services.tailscale.enable {
    "tailscale0".allowedTCPPorts = [ 22 ];
  };
}
