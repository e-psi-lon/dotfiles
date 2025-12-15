{ config, pkgs, lib, ... }:

{
    environment = {
        systemPackages = with pkgs; [
            jetbrains-toolbox
            bat
            glow
            ripgrep
            fd
            jq
            dust
            vesktop
            bash
            pciutils

            # JDKs
            jdk8
            jdk11
            jdk21
            jdk25
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
