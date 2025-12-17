{ config, pkgs, lib, ... }:

{
    boot.loader = {
        efi.canTouchEfiVariables = lib.mkDefault true;
    };

    networking = {
        networkmanager.enable = true;
        resolvconf.enable = false;
    };

    time.timeZone = "Europe/Paris";

    i18n.defaultLocale = "en_US.UTF-8";

    services = {
        tailscale = {
            enable = true;
            useRoutingFeatures = "both";
            permitCertUid = "e-psi-lon";
        };

        xserver.xkb = {
            layout = "fr";
            variant = "";
        };

        resolved.enable = true;

        pipewire = {
            enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
            pulse.enable = true;
        };

        flatpak.enable = true;

        fail2ban = {
            enable = true;
            bantime = "10m";
            bantime-increment.enable = true;
            maxretry = 5;
        };

        openssh = {
            enable = true;
            settings = {
                PasswordAuthentication =  false;
                PermitRootLogin = "no";
                X11Forwarding =  true;
                MaxAuthTries = 4;
            };
        };
    };

    programs = {
        ssh.startAgent = true;
        zsh.enable = true;
    };

    environment = {
        variables = {
            EDITOR = "nvim";
        };
        systemPackages = with pkgs; [
            neovim
            wget
            git
            networkmanager
            fzf
            fastfetch
            atuin
            gh
            uv
            eza
            stow
            nano
            rsync
            curl
            zip
            unzip
            htop
            tree
            python3
            ffmpeg
            vscode
            php
            gcc
            nasm
            firefox
            libreoffice-qt
            prismlauncher
            waypipe
            openvpn
            zoxide
            oh-my-posh
        ];
    };


    console.keyMap = "fr";

    users.users.e-psi-lon = {
        isNormalUser = true;
        description = "e_ψ_lon";
        extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "storage" ];
        shell = pkgs.zsh;
        hashedPassword = "$6$RuWluSDrWlxlvRqQ$JCiJFbeooSAfaKV0BkcCx6g/wxxSH9oDpUbAn5EG6Ee/aG5hZ3zt9UVKUnRxbF6ELDFj71yvUdEpi/.aglaj1/";
        createHome = true;
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMj8zKRB39dPABSBPDkRU+yrgFP2iQaCkJvNLJ9D4/7X e-psi-lon@nixos-hp"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdsCJp/3BQiAzscw2PT8rmfVWYwd7gVJca0QKWkpnSm e-psi-lon@home"
        ];
    };

    programs.appimage.enable = true;
    programs.appimage.binfmt = true;

    fonts.fontconfig = {
        enable = true;

        defaultFonts = {
            sansSerif = [ "NotoSans Nerd Font" "NotoSans Nerd Font" ];
            monospace = [ "JetBrainsMono Nerd Font" ];
            serif = [ "NotoSerif Nerd Font" ];
            emoji = [ "Noto Color Emoji" ];
        };
    };

    nixpkgs.config.allowUnfree = true;

    nix = {
        gc.automatic = true;

        optimise.automatic = true;

        settings = {
            auto-optimise-store = true;
            experimental-features = [ "nix-command" "flakes" ];
        };
    };

    fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        nerd-fonts.noto
    ];
}
