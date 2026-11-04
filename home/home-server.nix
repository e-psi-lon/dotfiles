{ paths, ... }:
{
  imports = [
    (paths.home-modules + "/computer")
  ];

  home.persistence."/persist".directories = [
    ".config/atuin"
    ".config/gh"
    ".config/sops/age"
    ".local/share"
    "dotfiles"
  ];

  home.stateVersion = "26.11";
}
