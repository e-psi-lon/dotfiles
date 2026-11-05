{ 
  boot = {
    kernelParams = [
      "console=ttyAMA0"
    ];
    tmp = {
      useZram = true;
      zramSettings.zram-size = "ram * 0.25";
    };
    initrd.systemd.emergencyAccess = true;
    loader.limine.secureBoot.enable = false;
  };
}
