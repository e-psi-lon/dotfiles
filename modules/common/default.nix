{
  pkgs,
  lib,
  config,
  username,
  subPath,
  paths,
  ...
}:

{
  imports = [
    ./locale-time.nix
    ./networking.nix
    ./services.nix
    ./packages.nix
    ./fonts.nix
    ./programs.nix
    ./sops.nix
  ];

  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  sops.secrets."e-psi-lon/password" = {
    sopsFile = subPath paths.resources "secrets/password.shared.yaml";
    neededForUsers = true;
  };


  users.groups.${username} = { 
    members = [ username ];
  };
  users.users.${username} = {
    isNormalUser = true;
    group = username;
    description = "e_ψ_lon";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "storage"
      "disk"
    ];
    hashedPasswordFile = config.sops.secrets."e-psi-lon/password".path;
    createHome = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMj8zKRB39dPABSBPDkRU+yrgFP2iQaCkJvNLJ9D4/7X ${username}@nixos-hp"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdsCJp/3BQiAzscw2PT8rmfVWYwd7gVJca0QKWkpnSm ${username}@home"
    ];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix = {
    gc.automatic = lib.mkDefault true;
    optimise.automatic = lib.mkDefault true;
    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  environment.sessionVariables = {
    EDITOR = lib.mkDefault "nvim";
  };
}
