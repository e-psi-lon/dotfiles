{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./common.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      configurationLimit = 2;
    };
  };

  networking = {
    hostName = "nixos-laptop";
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
    initialHashedPassword = "$6$RuWluSDrWlxlvRqQ$JCiJFbeooSAfaKV0BkcCx6g/wxxSH9oDpUbAn5EG6Ee/aG5hZ3zt9UVKUnRxbF6ELDFj71yvUdEpi/.aglaj1/";
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


  system.stateVersion = "25.05"; 
}
