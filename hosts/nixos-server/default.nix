{
  config,
  lib,
  modulesPath,
  ...
}:
{

  imports = [
    ./boot.nix
    ./disko.nix
    ./impermanence.nix
    ./services
    ./networking.nix
    ./vm.nix
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
    mainDomain = "e-psi-lon.dev";
    sops = {
      age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
      defaultSopsFile = config.paths.secretsDir + "/default.server.yaml";
      secrets = {
        cloudflare-acme-credentials = {
          sopsFile = config.paths.secretsDir + "/cloudflare-dns.server.txt";
          format = "binary";
        };
      };
    };
    
    users.users.${config.username}.openssh.authorizedKeys.keys = with config.sshKeys; [
      home-hp
      my-phone
      home-asus
      server # Trust itself
    ];
    documentation.enable = false;
    virtualisation.podman.dockerSocket.enable = true;

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
    system.stateVersion = "26.11";
  };
}
