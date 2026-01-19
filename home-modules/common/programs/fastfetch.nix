{ paths, subPath, ... }:
let
  ff = import (subPath paths.lib "fastfetch");
  inherit (ff) green cyan yellow magenta red override fastfetchModules;
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      display = {
        key.type = "both-2";
        color = "dim_white";
      };
      modules = with fastfetchModules; [
        (override title {
          color = {
            user = "cyan";
            at = "default";
            host = "blue";
          };
        })
        separator
        os
        host
        kernel
        uptime
        packages

        (green shell {})
        (green terminal {})
        (green de {})
        (green wm {})

        (cyan cpu {
          format = "{name} ({cores-physical}C/{cores-logical}T) @ {freq-base} ({freq-max})";
        })
        (cyan gpu {})

        (yellow memory {})
        (yellow swap {})
        (yellow disk {
          showExternal = false;
        })

        (magenta display {
          format = "{width}x{height} @ {refresh-rate}″ Hz in {inch} [{type}]";
        })
        (magenta wifi {})
        (magenta localip {
          format = "{ipv4} @ {speed} ({mac})";
        })

        (red battery {
          format = "{capacity-bar} {capacity}% [{status}] {time-formatted}";
          percent = {
            type = [ "num" "num-color" "bar" ];
            green = 80;
            yellow = 20;
          };
        })

        breakModule
        colors
      ];
    };
  };
}
