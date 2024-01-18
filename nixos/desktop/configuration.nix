# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ../shared/locale/configuration.nix
  ];
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):

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
    # System tools
    age
    alejandra
    direnv
    docker
    docker-compose
    git-filter-repo
    home-manager
    htop
    oh-my-zsh
    pciutils
    rsync
    wget
    zsh

    # KDE/QT
    krunner-translator
    libsForQt5.discover
    libsForQt5.kcalc
    libsForQt5.kdepim-addons
    libsForQt5.kirigami2
    libsForQt5.kdeconnect-kde
    libsForQt5.krunner-ssh
    libsForQt5.krunner-symbols
    libsForQt5.packagekit-qt
    libportal-qt5

    # System libraries
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji

    # User tools
    noisetorch
  ];

  programs.direnv = {
    enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  hardware.opengl.driSupport32Bit = true; # Enables support for 32bit libs that steam uses

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";
  programs.kdeconnect.enable = true;

  # Enable flatpak support
  services.flatpak.enable = true;
  services.packagekit.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "terminate:ctrl_alt_bksp,compose:caps_toggle";
  };

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

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  users.users = {
    lillian = {
      isNormalUser = true;
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf" "docker"];
      shell = pkgs.zsh;
    };
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];
}
