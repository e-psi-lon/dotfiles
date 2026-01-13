{ config, pkgs, lib, ... }:

{
  imports = [
    ./locale-time.nix
    ./networking.nix
    ./services.nix
    ./packages.nix
    ./fonts.nix
    ./programs.nix
  ];

  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  users.users.e-psi-lon = {
      isNormalUser = true;
      description = "e_ψ_lon";
      shell = pkgs.zsh;
      extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "storage" ];
      hashedPassword = "$6$RuWluSDrWlxlvRqQ$JCiJFbeooSAfaKV0BkcCx6g/wxxSH9oDpUbAn5EG6Ee/aG5hZ3zt9UVKUnRxbF6ELDFj71yvUdEpi/.aglaj1/";
      createHome = true;
      openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMj8zKRB39dPABSBPDkRU+yrgFP2iQaCkJvNLJ9D4/7X e-psi-lon@nixos-hp"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdsCJp/3BQiAzscw2PT8rmfVWYwd7gVJca0QKWkpnSm e-psi-lon@home"
      ];
  };

  nixpkgs.config.allowUnfree = lib.mkDefault true;

  nix = {
    gc.automatic = lib.mkDefault true;
    optimise.automatic = lib.mkDefault true;
    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  environment.sessionVariables = {
    EDITOR = lib.mkDefault "nvim";
  };
}
