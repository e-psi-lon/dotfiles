{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./programs
  ];

  home = {
    username = "e-psi-lon";
    homeDirectory = "/home/e-psi-lon";

    shell = {
      enableZshIntegration = true;
    };
    shellAliases = {
      cls = "clear; ${pkgs.fastfetch}/bin/fastfetch";
      la = "ls -a";
      lla = "ls -la";
      cdl = "${pkgs.zoxide}/bin/zoxide query -l -s";
      grep = "grep --color=auto";
      # act = "gh act";
      edit = "$EDITOR";
      shrug = "echo '¯\\_(ツ)_/¯'";
      # It's important to be kind with your computer :)
      please = "sudo";
    };
  };
  xdg.enable = true;
}
