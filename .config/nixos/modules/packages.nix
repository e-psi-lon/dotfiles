{ pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    # System utilities
    pciutils
    usbutils
    
    # Basic utilities
    stow # TODO: Remove once dotfiles are migrated to home-manager
    git
    rsync
    curl
  ]);
}
