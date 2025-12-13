{ config, pkgs, zen-browser, ... }:

{
    environment.systemPackages = [
        zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
}