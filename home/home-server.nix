{ paths, config, ... }:
{
  imports = [
    (paths.home-modules + "/computer")
  ];
  selfKey = config.sshKeys.server;
  selfKeyPrivPath = "${config.home.homeDirectory}/.ssh/ssh_ed25519";

  home.persistence."/persist".directories = [
    ".config/atuin"
    ".config/gh"
    ".config/sops/age"
    ".local/share"
    "dotfiles"
    ".ssh"
  ];

  home.stateVersion = "26.11";
}
