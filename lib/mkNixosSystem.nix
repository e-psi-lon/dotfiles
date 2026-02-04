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
    let
      hashesFile = subPath paths.resources "/hashes.toml";
      hashes = fromTOML (builtins.readFile hashesFile);
      args = extraArgs // { inherit paths subPath hashes; };
    in
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = args;
      modules = modules ++ [
        (paths.hosts + "/nixos-${machineName}")
        { networking.hostName = "nixos-${machineName}"; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.e-psi-lon = (paths.home + "/home-${machineName}.nix");
          home-manager.extraSpecialArgs = args;
        }
      ];
    };
}
