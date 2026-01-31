{ ... }:

{
  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };

    thermald.enable = true;
    journald.extraConfig = ''
      SystemMaxUse=5M
      RuntimeMaxUse=50M
    '';

    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };
  };

  zramSwap = {
    enable = true;
    # CONSIDER: adjust size as needed
    # memoryPercent = 50;
  };

  boot = {
    tmp.cleanOnBoot = true;
    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.vfs_cache_pressure" = 60;
      "vm.oom_kill_allocating_task" = 1;
      "vm.panic_on_oom" = 0;
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    optimise.automatic = true;

    settings = {
      keep-outputs = false;
      keep-derivations = false;
      max-jobs = 2;
      auto-optimise-store = true;
    };
  };

  systemd.settings.Manager.DefaultMemoryAccounting = true;
}
