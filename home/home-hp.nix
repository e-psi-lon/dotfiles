{ 
  pkgs,
  paths,
  subPath,
  ...
}:

{
  imports = [
    (subPath paths.home-modules "common")
  ];

  home.stateVersion = "25.11";
  programs.nixvim.colorschemes.onedark.enable = true;

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
