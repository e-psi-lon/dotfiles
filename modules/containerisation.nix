{ lib, username, ... }:

{
  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = lib.mkDefault false;
    dockerCompat = true;
    defaultNetwork.settings = {
      dns_enabled = true;
    };
  };

  users.users.${username} = {
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

  networking.nftables.enable = true;
  networking.nftables.tables.port-forward = {
    family = "ip";
    content = ''
      chain prerouting {
        type nat hook prerouting priority -100;
        tcp dport 80 redirect to :50080
        tcp dport 443 redirect to :50443
      }

      chain output {
        type nat hook output priority -100;
        ip daddr 127.0.0.1 tcp dport 80 redirect to :50080
        ip daddr 127.0.0.1 tcp dport 443 redirect to :50443
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 50080 50443 ];

}
