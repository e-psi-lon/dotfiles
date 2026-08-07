{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./../base
    ./locale-time.nix
    ./networking.nix
    ./services.nix
  ];

  options = {
    paths.sshToml = lib.mkOption {
      type = lib.types.path;
      description = "The path to the ssh.toml file.";
    };
    sshKeys = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "The available ssh keys for evaluation.";
    };
    personalId = lib.mkOption {
      type = lib.types.int;
      default = 1000;
      description = "The personal ID for the user (used for both UID and GID).";
    };
  };

  config = {
    sshKeys = lib.mkDefault (fromTOML (builtins.readFile config.paths.sshToml)).keys;
    sops.secrets."${config.username}/password" = {
      sopsFile = "${config.paths.secretsDir}/password.shared.yaml";
      neededForUsers = true;
    };

    users = {
      mutableUsers = lib.mkDefault true;
      groups.${config.username} = {
        gid = config.personalId;
        members = [ config.username ];
      };
      users.${config.username} = {
        uid = config.personalId;
        isNormalUser = true;
        group = config.username;
        description = config.displayName;
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
          "storage"
          "disk"
        ];
        hashedPasswordFile = config.sops.secrets."${config.username}/password".path;
        createHome = true;
      };
    };
  };
}
