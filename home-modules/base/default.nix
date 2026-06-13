{ nixvim, config, pkgs, lib, ... }:

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
    hashes = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      description = "The available hashes for evaluation.";
    };
  };

  config = {
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
      sessionVariables.EDITOR = lib.getExe pkgs.neovim;
    };
    xdg.enable = true;
    programs.nixvim.imports = [ ./neovim.nix ];
  };
}
