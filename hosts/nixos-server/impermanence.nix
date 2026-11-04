{
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/acme"
      "/var/lib/gokapi"
      "/var/lib/nixos"
      "/var/lib/postgresql"
      "/var/lib/redis"
      "/var/lib/systemd"
      "/var/lib/vaultwarden"
      "/var/backup/postgresql"
    ];

    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };
}
