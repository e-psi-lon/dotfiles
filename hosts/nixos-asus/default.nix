{ pkgs, config, ... }:

{

  imports = [
    # ./disko.nix
    ./boot.nix
    ./hardware-configuration.nix
    ./hardware.nix
    ./services.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      tpm2-tss
    ];
  };

  users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
    home-hp
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

  sops.secrets.cloudflare-acme-credentials.sopsFile = "${config.paths.secretsDir}/cloudflare-dns.asus.txt";

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@e-psi-lon.dev";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-acme-credentials".path;
      };
    };

    certs."e-psi-lon.dev" = {
      domain = "e-psi-lon.dev";
      extraDomainNames = [ "*.e-psi-lon.dev" ];
    };

    certs."int.e-psi-lon.dev" = {
      domain = "int.e-psi-lon.dev";
      extraDomainNames = [ "*.int.e-psi-lon.dev" "*.home.int.e-psi-lon.dev" ];
    };
  };

  system.stateVersion = "26.05";
}
