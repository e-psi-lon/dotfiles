{
  config,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    ./impermanence.nix
    ./services
    ./networking.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options = {
    mainDomain = lib.mkOption {
      type = lib.types.str;
    };
    mainInternalDomain = lib.mkOption {
      type = lib.types.str;
      default = "int.${config.mainDomain}";
    };
  };

  config = {
    sops.secrets.cloudflare-acme-credentials = {
      sopsFile = config.paths.secretsDir + "/cloudflare-dns.server.txt";
      format = "binary";
    };
    users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
      home-hp
      my-phone
      home-asus
      server # Trust itself
    ];
    boot = {
      kernelParams = [
        "console=ttyAMA0"
      ];
      tmp = {
        useZram = true;
        zramSettings.zram-size = "ram * 0.25";
      };
      loader.limine.secureBoot.enable = false;
    };
    mainDomain = "e-psi-lon.dev";
    documentation.enable = false;

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

    services.cloudflare-dyndns = {
      enable = true;
      deleteMissing = true;
      ipv4 = true;
      ipv6 = true;
      proxied = false;
      apiTokenFile = config.sops.secrets.cloudflare-acme-credentials.path;
      domains = [
        "files.${config.mainDomain}"
        "vault.${config.mainDomain}"
      ];
    };
    system.stateVersion = "26.11";
  };
}
