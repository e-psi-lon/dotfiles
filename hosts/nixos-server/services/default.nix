{ config, ... }:
{
  imports = [
    ./acme.nix
    ./forgejo.nix
    ./gokapi.nix
    ./mail.nix
    ./monitoring.nix
    ./nginx.nix
    ./podman.nix
    ./postgres.nix
    ./redis.nix
    ./restic.nix
    ./vaultwarden.nix
  ];

  config = {
    sops.secrets = {
      "tailscale/auth-key".restartUnits = [ "tailscaled-autoconnect.service" ];
      cloudflare-acme-credentials.restartUnits = [ "cloudflare-dyndns.service" ];
    };
    services = {
      qemuGuest.enable = true;
      tailscale.authKeyFile = config.sops.secrets."tailscale/auth-key".path;
      openssh = { 
        ports = [ 22 ];
        extraConfig = ''
          Match LocalPort 22
            AllowUsers ${config.username}
        '';
        settings.X11Forwarding = false;
      };
      cloudflare-dyndns = {
        enable = true;
        deleteMissing = true;
        ipv4 = true;
        ipv6 = true;
        proxied = false;
        apiTokenFile = config.sops.secrets.cloudflare-acme-credentials.path;
        domains = [
          "files.${config.mainDomain}"
          "vault.${config.mainDomain}"
          "git.${config.mainDomain}"
        ];
      };
    };
  };
}
