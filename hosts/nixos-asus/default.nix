{ pkgs, config, ... }:

{

  imports = [
    ./disko.nix
    ./boot.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./services.nix
  ];

  networking.networkmanager.settings = {
    "connection-wifi" = {
      match-device = "type:wifi";
      "ipv4.route-metric" = 50;
      "ipv6.route-metric" = 50;
    };
    "connection-ethernet" = {
      match-device = "type:ethernet";
      "ipv4.route-metric" = 100;
      "ipv6.route-metric" = 100;
    };
  };

  environment.systemPackages = with pkgs; [
    cryptsetup
    tpm2-tss
  ];

  tpmUnlockPcrs = "0+2+4";

  users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
    home-hp
    my-phone
    home-asus # Trust itself
  ];
  services = {
    desktopManager.plasma6.notoPackage = pkgs.nerd-fonts.noto;
    joycond.enable = true;
  };

  programs.fuse.enable = true;

  nix = {
    optimise.automatic = true;
    settings.trusted-users = [
      "root"
      config.username
    ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  networking = {
    firewall.allowedTCPPorts = [
      50080
      50443
    ];
    nftables = {
      tables =
        let
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
        in
        {
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

  system.stateVersion = "26.05";
}
