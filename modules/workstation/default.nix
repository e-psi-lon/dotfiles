{ config, ... }:

{
  imports = [
    ../computer
    ./fonts.nix
    ./locale.nix
    ./networking.nix
    ./programs.nix
    ./services.nix
  ];

  # Hardware access groups for local interactive seats
  users.users.${config.username}.extraGroups = [ "audio" "video" "input" ];
}