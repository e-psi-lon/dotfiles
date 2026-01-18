{
  mkNixosSystem =
    {
      pkgs,
      home-manager,
      modules,
      machineName,
      extraArgs ? { },
    }:
    pkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = extraArgs;
      modules = modules ++ [
        ("../hosts/nixos-${machineName}")
        { networking.hostName = "nixos-${machineName}"; }
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.e-psi-lon = ("../home/home-${machineName}.nix");
          home-manager.extraSpecialArgs = extraArgs;
        }
      ];
    };
}
