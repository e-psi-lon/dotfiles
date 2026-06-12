{ config, lib, pkgs, ... }:
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
  };

  config = {
    sshKeys = lib.mkDefault (fromTOML (builtins.readFile config.paths.sshToml)).keys;
    sops.secrets."${config.username}/password" = {
      sopsFile = "${config.paths.secretsDir}/password.shared.yaml";
      neededForUsers = true;
    };

    users.groups.${config.username} = {
      members = [ config.username ];
    };

    users.users.${config.username} = {
      isNormalUser = true;
      group = config.username;
      description = config.displayName;
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "storage" "disk" ];
      hashedPasswordFile = config.sops.secrets."${config.username}/password".path;
      createHome = true;
    };
  };
}