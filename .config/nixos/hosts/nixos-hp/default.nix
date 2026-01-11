{ config, pkgs, ... }:

{

    imports = [
      ./hardware-configuration.nix
      ./optimization.nix
    ];

    boot = {
        loader.systemd-boot = {
            enable = true;
            configurationLimit = 2;
        };

        blacklistedKernelModules = [ "intel-spi" ];
    };

    hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
            intel-vaapi-driver
            libvdpau-va-gl
        ];
    };

    services.xserver.videoDrivers = [ "intel" ];

    environment = {
        sessionVariables = {
            LIBVA_DRIVER_NAME = "i965";
	    };
        enableDebugInfo = false;

        systemPackages = with pkgs; [
	        moonlight-qt
            (retroarch.withCores(cores: with cores; [
                nestopia
                gambatte
                mgba
                melonds
            ]))
        ];
    };

    system.stateVersion = "25.05";
    
}
