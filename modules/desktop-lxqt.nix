{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      desktopManager.lxqt = {
        enable = true;
        extraPackages = with pkgs; [
          lxqt.qterminal
          lxqt.pcmanfm-qt
          lxqt.lxqt-runner
          lxqt.lxqt-wayland-session
          labwc
          openbox
        ];
      };
    };

    displayManager.sddm.enable = true;
  };
}
