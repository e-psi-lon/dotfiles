{ pkgs, ... }:
{

  services = {
      sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
      };
      openvpn.servers = {
        univ-tours = { 
          config = '' config /home/e-psi-lon/.config/openvpn/vpnfr-etu-TCP4-443.ovpn '';
          up = ''( pkgs, ... ):
            ${pkgs.systemd}/bin/resolvectl dns tun0 10.195.2.1 10.196.20.10 10.195.2.2
            ${pkgs.systemd}/bin/resolvectl domain tun0 '~univ-tours.local' '~univ-tours.fr'
          '';

          down = ''
            ${pkgs.systemd}/bin/resolvectl revert tun0
          '';
          autoStart = false;
        };
      };
      udev.packages = [
        (pkgs.writeTextFile {
          name = "numworks-udev-rule";
          destination = "/etc/udev/rules.d/50-numworks-calculator.rules";
          text = builtins.readFile (pkgs.fetchurl {
            url = "https://cdn.numworks.com/f2be8a48/50-numworks-calculator.rules";
            sha256 = "sha256-x4leQyuSdNsXwpZRZPUJWkJNZDRl2WhqC3PHizChe8w=";
          });
        })
      ];
  };
}