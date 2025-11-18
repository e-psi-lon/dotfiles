{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      configurationLimit = 2;
    };
  };

  networking = {
    hostName = "nixos-laptop"; # Define your hostname.
    networkmanager.enable = true;

    resolvconf.enable = false;
    firewall = {
      allowedTCPPorts = [ 
        22
        3000
        8080
        80
        9000
      ];
      allowedUDPPorts = [ ];
      enable = true;
    };
  };

  
  # Set your time zone
  time.timeZone = "Europe/Paris"; # French timezone

  # Internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11 (French AZERTY)
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "fr";
        variant = "";
      };
      # Enable LXQt desktop environment
      desktopManager.lxqt.enable = true;
    };
    displayManager = {
      sddm.enable = true;
    };
    
    tailscale = {
      enable = true;
      useRoutingFeatures = "both";
    };

    resolved = {
      enable = true;
    };

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      };
    };

    thermald.enable = true;

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
      maxretry = 3;
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
    };

    journald.extraConfig = ''
    SystemMaxUse=100M
    RuntimeMaxUse=50M
    '';
  };

  programs = {
    ssh.startAgent = true;
    zsh.enable = true;
  };

  environment = {
    variables = {
      EDITOR = "nvim";
    };
    enableDebugInfo = false;
  };
  


  # Configure console keymap (French AZERTY)
  console.keyMap = "fr";

  hardware = {
    graphics.enable = true;
  };


  # Define a user account with zsh as default shell
  users.users.lilian-maulny = {
    isNormalUser = true;
    description = "Lilian Maulny";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "input" "storage" ];
    shell = pkgs.zsh;
    initialHashedPassword = "$6$UeD2moIWjO4alet3$dwuUSswjqgFzZ//HTrm7fMSQ5JAsDPGAWvcU9OAoaUdT98tNihS.okJ.MflmLSiIwfYJMISKPdHlp3UnU8YLi0";
    createHome = true;
  };

  fonts.fontconfig.enable = true;

  # Enable automatic login for the user
  # services.xserver.displayManager.autoLogin.enable = true;
  # services.xserver.displayManager.autoLogin.user = "lilian-maulny";

  # Allow unfree packages (needed for VSCode)
  nixpkgs.config.allowUnfree = true;

  system.activationScripts.flatpak-repo = {
    text = ''
      if ! ${pkgs.flatpak}/bin/flatpak remotes | grep -q flathub; then
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo --system || true
      fi
    '';
  };

  # List packages installed in system environment (system-wide for efficiency)
  environment = {
    systemPackages = with pkgs; [
      # Essential system tools
      neovim
      wget
      git
      networkmanager
  
      # Shell and terminal productivity tools
      fzf
      fastfetch
      zoxide
      stow
      eza
      uv
      atuin
      gh
      oh-my-posh
      nano
      rsync
    
      # Development languages and tools
      python3
      ffmpeg
      php
      vscode
      gcc
      nasm
    
      # Applications
      firefox
      libreoffice-qt
      prismlauncher
      waypipe
      (
        retroarch.withCores(cores: with cores; [
          nestopia
	  gambatte
	  mgba
	  melonds
	 ])
      )
    
      # Utilities
      htop
      tree
      curl
      zip
      unzip
      openvpn

      # LXQt specific tools
      lxqt.qterminal
      lxqt.pcmanfm-qt
      lxqt.lxqt-runner
      lxqt.lxqt-wayland-session
      labwc
      openbox
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
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      keep-outputs = false;
      keep-derivations = false;
    };
  };

  # Reduce swappiness for better performance with limited RAM
  boot.kernel.sysctl = {
    "vm.swappiness" = 5;
    "vm.vfs_cache_pressure" = 60;
  };

  systemd.extraConfig = ''
    DefaultMemoryAccounting=yes
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this value to
  # understand what choosing a different value implies.
  system.stateVersion = "25.05"; # Don't change this after installation

}
