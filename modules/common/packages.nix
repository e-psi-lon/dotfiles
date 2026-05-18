{ pkgs, ... }:

{
  environment.systemPackages = (
    with pkgs;
    [
      # System utilities
      pciutils
      usbutils

      # Basic utilities
      git
      rsync
      curl
      sops
      age
    ]
  );
}
