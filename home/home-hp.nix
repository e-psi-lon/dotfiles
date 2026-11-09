{
  pkgs,
  paths,
  config,
  ...
}:

{
  imports = [ (paths.home-modules + "/workstation") ];

  home.stateVersion = "26.05";
  programs.nixvim.colorschemes.onedark.enable = true;
  selfKey = config.sshKeys.home-hp;
  selfKeyPrivPath = "${config.home.homeDirectory}/.ssh/ssh_ed25519_hp";

  home.packages = with pkgs; [
    firefox
    moonlight-qt
    socat
    # CONSIDER: Keep some local RetroArch vs. 100% remote streaming. Local might not be useful
    (retroarch.withCores (
      cores: with cores; [
        nestopia
        gambatte
        mgba
      ]
    ))
  ];
}
