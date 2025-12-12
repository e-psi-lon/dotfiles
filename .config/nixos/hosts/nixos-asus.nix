{ config, pkgs, ... }:

{
    environment = {
        systemPackages = with pkgs; [
            jetbrains-toolbox

        ];
    };

    hardware.nvidia.prime = {
        sync.enable = true;

        amdgpuBusId = "PCI:6:0:0";
        nvidiaBusId = "PCI:1:0:0";
    }
}