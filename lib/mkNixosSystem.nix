{
  mkNixosSystem =
    allArgs@{
      pkgs,
      home-manager,
      modules,
      machineName,
      paths,
      subPath,
      hashes,
      flakeRev,
      ...
    }:
    let
      username = "e-psi-lon";
      extraArgs = removeAttrs allArgs [
        "pkgs"
        "home-manager"
        "modules"
        "machineName"
      ];
      args = extraArgs // { inherit hashes username; } // (import (subPath paths.lib "mkBindMount.nix"));
    in
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = args;
      modules = modules ++ [
        allArgs.sops-nix.nixosModules.sops
        (paths.hosts + "/nixos-${machineName}")
        { 
          networking.hostName = "nixos-${machineName}"; 
          system.configurationRevision = flakeRev;
        }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = (paths.home + "/home-${machineName}.nix");
          home-manager.extraSpecialArgs = args;
        }
      ];
    };
}
