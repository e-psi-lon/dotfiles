{ pkgs, lib, ... }:
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
}
