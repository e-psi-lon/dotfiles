{ config, pkgs, ... }:

{

    boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 2;
    };

    hardware.graphics = {
        enable = true;
	extraPackages = with pkgs; [
	    intel-vaapi-driver
	    libvdpau-va-gl
	];
    };

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
            SystemMaxUse=10M
            RuntimeMaxUse=50M
        '';

        xserver.videoDrivers = [ "intel" ];
    };

    environment = {
        sessionVariables = {
            LIBVA_DRIVER_NAME = "i965";
	};
        enableDebugInfo = false;

        systemPackages = with pkgs; [
	    moonlight-qt
            (
                retroarch.withCores(cores: with cores; [
                    nestopia
                    gambatte
                    mgba
                    melonds
                ])
            )
        ];
    };

    zramSwap.enable = true;

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
        };
    };

    boot.kernel.sysctl = {
        "vm.swappiness" = 5;
        "vm.vfs_cache_pressure" = 60;
    };

    boot.blacklistedKernelModules = [ "intel-spi" ];


    systemd.settings.Manager.DefaultMemoryAccounting = true;

    system.stateVersion = "25.05";
    
}
