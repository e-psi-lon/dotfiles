{ config, lib, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = lib.mkDefault false;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  users.users.${config.username} = {
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
  };
  networking = {
    firewall.allowedTCPPorts = [ 
      50080 
      50443
    ];
    nftables = {
      enable = true;
      tables = let 
        content = ''
          chain prerouting {
            type nat hook prerouting priority -100;
            tcp dport 80 redirect to :50080
            tcp dport 443 redirect to :50443
          }

          chain output {
            type nat hook output priority -100;
            fib daddr type local tcp dport 80 redirect to :50080
            fib daddr type local tcp dport 443 redirect to :50443
          }
        '';
      in {
        port-forward-v6 = {
          family = "ip6";
          content = content;
        };
        port-forward-v4 = {
          family = "ip";
          content = content;
        };
      };
    };
  };

}
