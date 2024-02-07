{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    #Jovian Nixos
    inputs.jovian.nixosModules.jovian
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    inputs.home-manager.nixosModules.home-manager
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # Import the locale settings
    ../../shared

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "";
  services.openssh.enable = true;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      inputs.extest.overlays.default

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  #Set up sops config, and configure where the keyfile is, then set the mode for the unencrypted keys
  sops.defaultSopsFile = ./secrets/sops.yaml;
  sops.age.keyFile = ./keys.txt;

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  environment.systemPackages = with pkgs; [
    #System:
    alejandra
    btrfs-progs
    git
    git-filter-repo
    home-manager
    htop
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji
    oh-my-zsh
    rsync
    wget
    zsh

    #KDE:
    krunner-translator
    libsForQt5.discover
    libsForQt5.kcalc
    libsForQt5.kdepim-addons
    libsForQt5.kirigami2
    libsForQt5.kdeconnect-kde
    libsForQt5.krunner-ssh
    libsForQt5.krunner-symbols
    libsForQt5.packagekit-qt
    libsForQt5.qt5.qtvirtualkeyboard
    libportal-qt5

    #Gaming:
    heroic
    legendary-gl
    rare
  ];

  #Enable steam deck steam interface
  jovian.steam.enable = true;

  #Autostart this inteface at login
  jovian.steam.autoStart = true;

  #What desktop to start when switching to desktop session
  jovian.steam.desktopSession = "plasmawayland";

  jovian.steam.user = "lillian";

  #Enable gyro service for CEMU
  jovian.devices.steamdeck.enableGyroDsuService = true;

  #Enable steam deck specific services
  jovian.devices.steamdeck.enable = true;

  #Enable auto updates for the BIOS and controller firmware
  jovian.devices.steamdeck.autoUpdate = true;

  jovian.decky-loader.enable = true;

  jovian.hardware.has.amd.gpu = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    package = pkgs.steam.override {
      extraProfile = ''export LD_PRELOAD=${pkgs.extest}/lib/libextest.so:$LD_PRELOAD'';
    };
  };
  hardware.opengl.driSupport32Bit = true; # Enables support for 32bit libs that steam uses

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.desktopManager.plasma5.enable = true;
  programs.kdeconnect.enable = true;

  services.xserver.displayManager.sddm.settings = {
    Autologin = {
      Session = "plasma.desktop";
      User = "lillian";
    };
  };

  # Enable flatpak support
  services.flatpak.enable = true;
  services.packagekit.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [22];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable bluetooth hardware
  hardware.bluetooth.enable = true;

  # Enable fwupd daemon and user space client
  services.fwupd.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.noisetorch = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
  };

  users.users = {
    lillian = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYgErCnva8fvLvsmTMC6dHJp2Fvwja0BYL8K/58ugDxNA0PVGj5PpEMar5yhi4AFGGYL4EgD75tRgI/WQU87ZiKjJ6HFIhgX9curncB2kIJ0JoA+FIQMNOT72GFuhjcO4svanrobsMrRmcn193suXY/N6m6F+3pitxBfHPWuPKKjlZqVBzpqCdz9pXoGOk48OSYv7Zyw8roVsUw3fqJqs68LRLM/winWVhVSPabXGyX7PAAW51Nbv6M64REs+V1a+wGvK5sGhRy7lIBAIuD22tuL4/PZojST1hasKN+7cSp7F1QTi4u0yeQ2+gIclQNuhfvghzl6zcVEpOycFouSIJaJjo8jyuHkbm4I2XfALVTFHe7sLpYNNS7Mf6E6i5rHvAvtXI4UBx/LjgPOj7RWZFaotxQRk1D+N0y2xNrO4ft6mS+hrJ/+ybp1XTGdtlkpUDKjiTZkV7Z4fq9J0jtijvtxRfcPhjia50IIHtZ28wVBMCCwYzh5pR15F/XbvKCc= lillian@EDI"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
      ];
      isNormalUser = true;
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf" "decky"];
      shell = pkgs.zsh;
    };
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/shodan/shodan-Lillian.nix;
    };
  };

  networking.hostName = "shodan";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "udev.log_priority=0"];
  boot.plymouth.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
