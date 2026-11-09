{
  nixvim,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    nixvim.homeModules.nixvim
    ./fastfetch.nix
    ./git.nix
    ./shell.nix
    ./zsh.nix
    ./sops.nix
    ./packages.nix
  ];

  options = {
    hasNvidiaGpu = lib.mkEnableOption "nvidia gpu";
    paths = {
      sshToml = lib.mkOption {
        type = lib.types.path;
        description = "The path to the ssh.toml file.";
      };
      hashesToml = lib.mkOption {
        type = lib.types.path;
        description = "The path to the hashes.toml file.";
      };
      secretsDir = lib.mkOption {
        type = lib.types.path;
        description = "The path to the secrets directory.";
      };
      resources = lib.mkOption {
        type = lib.types.path;
        description = "The path to the resources directory.";
      };
      libDirectory = lib.mkOption {
        type = lib.types.path;
        description = "The path to the lib directory.";
      };
    };
    sshKeys = lib.mkOption {
      type = lib.types.attrsOf (lib.types.str);
      description = "The available ssh keys for evaluation.";
    };
    selfKey = lib.mkOption {
      type = lib.types.str;
      description = "The main ssh key.";
    };
    selfKeyPrivPath = lib.mkOption {
      type = lib.types.path;
      description = "The path to the private key file of the main ssh key.";
    };
    hashes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      description = "The available hashes for evaluation.";
    };
  };

  config = {
    sshKeys = lib.mkDefault (fromTOML (builtins.readFile config.paths.sshToml)).keys;
    hashes = lib.mkDefault (fromTOML (builtins.readFile config.paths.hashesToml));
    home = {
      username = lib.mkDefault "e-psi-lon";
      homeDirectory = "/home/${config.home.username}";

      shell.enableZshIntegration = true;
      shellAliases = {
        cls = "clear; ${lib.getExe pkgs.fastfetch}";
        la = "ls -a";
        lla = "ls -la";
        cdl = "${lib.getExe pkgs.zoxide} query -l -s";
        grep = "grep --color=auto";
        # act = "gh act";
        edit = "$EDITOR";
        shrug = "echo '¯\\_(ツ)_/¯'";
        # It's important to be kind with your computer :)
        please = "sudo";
      };
    };
    xdg.enable = true;
    programs.nixvim = {
      defaultEditor = true;
      imports = [ ./neovim.nix ];
    };
  };
}
