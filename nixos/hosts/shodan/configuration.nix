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
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  #Set up sops config, and configure where the keyfile is, then set the mode for the unencrypted keys
  sops.defaultSopsFile = ./secrets/sops.yaml;

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
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kdepim-addons
    kdePackages.kirigami
    kdePackages.kdeconnect-kde
    # kdePackages.krunner-ssh
    # kdePackages.krunner-symbols
    kdePackages.qtvirtualkeyboard
    kdePackages.packagekit-qt
    libportal

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
  jovian.steam.desktopSession = "plasma";

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
  services.xserver.desktopManager.plasma6.enable = true;
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

  programs.git = {
    enable = true;
  };

  users.users.lillian.extraGroups = ["decky"];

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/shodan;
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
