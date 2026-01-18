{
  mkNixosSystem =
    {
      pkgs,
      home-manager,
      modules,
      machineName,
      paths,
      subPath,
      extraArgs ? { },
    }:
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = extraArgs // { inherit paths subPath; };
      modules = modules ++ [
        (paths.hosts + "/nixos-${machineName}")
        { networking.hostName = "nixos-${machineName}"; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.e-psi-lon = (paths.home + "/home-${machineName}.nix");
          home-manager.extraSpecialArgs = extraArgs // { inherit paths subPath; };
        }
      ];
    };
}
