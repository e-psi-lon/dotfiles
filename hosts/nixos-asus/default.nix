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

  sops.secrets.cloudflare-acme-credentials = {
    sopsFile = "${config.paths.secretsDir}/cloudflare-dns.asus.txt";
    format = "binary";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@e-psi-lon.dev";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-acme-credentials".path;
      };
    };

    certs = {
      "e-psi-lon.dev" = {
        domain = "e-psi-lon.dev";
        extraDomainNames = [ "*.e-psi-lon.dev" ];
      };

      "int.e-psi-lon.dev" = {
        domain = "int.e-psi-lon.dev";
        extraDomainNames = [
          "*.int.e-psi-lon.dev"
          "*.home.int.e-psi-lon.dev"
        ];
      };
    };
  };
  networking = {
    firewall.allowedTCPPorts = [
      50080
      50443
    ];
    nftables = {
      enable = true;
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
