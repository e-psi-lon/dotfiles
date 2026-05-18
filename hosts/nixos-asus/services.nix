{ pkgs, lib, paths, subPath, ... }:
{

  # systemd.user.services.sunshine.environment = {
  #   WAYLAND_DISPLAY = "wayland-1";
  # };
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
    printing.enable = true;

    openvpn.servers = {
      univ-tours = {
        config = "config ${subPath paths.resources "vpn/univ-tours.ovpn"}";
        up = ''
          ${lib.getExe' pkgs.systemd "resolvectl"} dns tun0 10.195.2.1 10.196.20.10 10.195.2.2
          ${lib.getExe' pkgs.systemd "resolvectl"} domain tun0 '~univ-tours.local' '~univ-tours.fr'
        '';

        down = ''
          ${lib.getExe' pkgs.systemd "resolvectl"} revert tun0
        '';
        autoStart = false;
      };
    };
    udev.packages = with pkgs; [ numworks-udev-rules ];
  };

  sops.secrets."univ-tours.ovpn" = {
    sopsFile = subPath paths.resources "secrets/univ-tours.asus.ovpn";
    format = "binary";
  };
}
