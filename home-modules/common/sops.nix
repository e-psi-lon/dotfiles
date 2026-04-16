{ config, sops-nix, ... }:

{
  imports = [ sops-nix.homeManagerModules.sops ];

  sops = {
    # Default age key location for user
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    # We specify a default secrets directory.
    # The default is normally ~/.config/sops-nix/secrets, but let's be explicit
    defaultSopsFormat = "yaml";
  };
}
