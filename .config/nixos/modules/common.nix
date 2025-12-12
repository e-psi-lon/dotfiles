{ config, pkgs, ... }:

{
    boot.loader = {
        efi.canTouchEfiVariables = true;
    };

    networking = {
        networkmanager.enable = true;
        resolvconf.enable = false;

        firewall = {
            allowedTCPPorts = [ 22 80 443 ];
            allowedUDPPorts = [ 22 ];
            enable = true;
        };
    };

    time.timeZone = "Europe/Paris";

    i18n.defaultLocale = "en_US.UTF-8";

    services = {
        tailscale = {
            enable = true;
            useRoutingFeatures = "both";
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
        extraGroups = [ "wheel" "networkmanager" "audio" "video" "input" "storage" ];
        shell = pkgs.zsh;
        hashedPassword = "$6$RuWluSDrWlxlvRqQ$JCiJFbeooSAfaKV0BkcCx6g/wxxSH9oDpUbAn5EG6Ee/aG5hZ3zt9UVKUnRxbF6ELDFj71yvUdEpi/.aglaj1/";
        createHome = true;
    };

    fonts.fontconfig.enable = true;

    nixpkgs.config.allowUnfree = true;

    nix = {
        gc.automatic = true;

        optimise.automatic = true;

        settings = {
            auto-optimise-store = true;
            experimental-features = [ "nix-command" "flakes" ];
        };
    };
}