{ config, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      desktopManager.lxqt.enable = true;
    };

    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lxqt.qterminal
    lxqt.pcmanfm-qt
    lxqt.lxqt-runner
    lxqt.lxqt-wayland-session
    labwc
    openbox
  ];
}
