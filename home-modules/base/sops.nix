{ config, sops-nix, ... }:

{
  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFormat = "yaml";
  };
}
