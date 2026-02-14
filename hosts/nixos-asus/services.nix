{ pkgs, ... }:
{

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
        # TODO: Use a more appropriate location for the ovpn file
        config = "config /home/e-psi-lon/.config/openvpn/vpnfr-etu-TCP4-443.ovpn ";
        up = ''
          ${pkgs.systemd}/bin/resolvectl dns tun0 10.195.2.1 10.196.20.10 10.195.2.2
          ${pkgs.systemd}/bin/resolvectl domain tun0 '~univ-tours.local' '~univ-tours.fr'
        '';

        down = ''
          ${pkgs.systemd}/bin/resolvectl revert tun0
        '';
        autoStart = false;
      };
    };
    udev.packages = with pkgs; [
      numworks-udev-rules
    ];
  };
}
