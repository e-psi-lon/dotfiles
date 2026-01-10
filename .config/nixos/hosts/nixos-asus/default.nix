{ config, pkgs, lib, ... }:

{

    imports = [
      ./hardware-configuration.nix
    ];
    
    environment = {
        systemPackages = with pkgs; [
            jetbrains-toolbox
            bat
            glow
            vesktop
	        (discord.override {
                withOpenASAR = true;
                withVencord = true;
            })
            bash
            pciutils
            nodejs_25
            gource


            # JDKs
            jdk8
            jdk11
            jdk21
            jdk25

            # Misc utilities
            ripgrep
            fd
            jq
            dust
            usbutils
            proton-pass

        ];
    };
    hardware = {
        nvidia.prime = {
            sync.enable = true;
            amdgpuBusId = "PCI:6:0:0";
            nvidiaBusId = "PCI:1:0:0";
        };
        bluetooth = {
            enable = true;
            powerOnBoot = true;
            settings = {
                General = {
                    Experimental = true;
                };
                Policy = {
                    AutoEnable = true;
                };
            };
        };
    };

    boot.loader.efi.efiSysMountPoint = "/boot/efi";

    users = {
        groups.data = {};
        users.e-psi-lon.extraGroups = lib.mkAfter [ "data" ];
    };

    systemd.tmpfiles.rules = [
        "d /mnt/data 0775 root data - -"
    ];

    services = {
        sunshine = {
            enable = true;
            autoStart = true;
            capSysAdmin = true;
            openFirewall = true;
        };
        openvpn.servers = {
            univ-tours = { 
                config = '' config /home/e-psi-lon/.config/openvpn/vpnfr-etu-TCP4-443.ovpn '';
                up = ''
                    ${pkgs.systemd}/bin/resolvectl dns tun0 10.195.2.1 10.196.20.10 10.195.2.2
                    ${pkgs.systemd}/bin/resolvectl domain tun0 '~univ-tours.local' '~univ-tours.fr'
                '';
                    
                down = ''
                    ${pkgs.systemd}/bin/resolvectl revert tun0
                '';
                autoStart = false;
            };
        };
        udev.packages = [
            (pkgs.writeTextFile {
                name = "numworks-udev-rule";
                destination = "/etc/udev/rules.d/50-numworks-calculator.rules";
                text = builtins.readFile (pkgs.fetchurl {
                    url = "https://cdn.numworks.com/f2be8a48/50-numworks-calculator.rules";
                    sha256 = "sha256-x4leQyuSdNsXwpZRZPUJWkJNZDRl2WhqC3PHizChe8w=";
                });
            })
        ];
    };

    nix = {
        optimise.automatic = true;

        gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
        };
    };

    programs.nix-ld.enable = true;

    programs.nix-ld.libraries = with pkgs; [
        SDL
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL_image
        SDL_mixer
        SDL_ttf
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        bzip2
        cairo
        cups
        curlWithGnuTls
        dbus
        dbus-glib
        desktop-file-utils
        e2fsprogs
        expat
        flac
        fontconfig
        freeglut
        freetype
        fribidi
        fuse
        fuse3
        gdk-pixbuf
        glew110
        glib
        gmp
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-ugly
        gst_all_1.gstreamer
        gtk2
        harfbuzz
        icu
        keyutils.lib
        libGL
        libGLU
        libappindicator-gtk2
        libcaca
        libcanberra
        libcap
        libclang.lib
        libdbusmenu
        libdrm
        libgcrypt
        libgpg-error
        libidn
        libjack2
        libjpeg
        libmikmod
        libogg
        libpng12
        libpulseaudio
        librsvg
        libsamplerate
        libthai
        libtheora
        libtiff
        libudev0-shim
        libusb1
        libuuid
        libvdpau
        libvorbis
        libvpx
        libxcrypt-legacy
        libxkbcommon
        libxml2
        mesa
        nspr
        nss
        openssl
        p11-kit
        pango
        pixman
        python3
        speex
        stdenv.cc.cc
        tbb
        udev
        vulkan-loader
        wayland
        xorg.libICE
        xorg.libSM
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXcomposite
        xorg.libXcursor
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXft
        xorg.libXi
        xorg.libXinerama
        xorg.libXmu
        xorg.libXrandr
        xorg.libXrender
        xorg.libXt
        xorg.libXtst
        xorg.libXxf86vm
        xorg.libpciaccess
        xorg.libxcb
        xorg.xcbutil
        xorg.xcbutilimage
        xorg.xcbutilkeysyms
        xorg.xcbutilrenderutil
        xorg.xcbutilwm
        xorg.xkeyboardconfig
        xz
        zlib
    ];


    system.stateVersion = "26.05";
}
