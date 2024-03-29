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

    ../../../disko/shodan

    ./auto-mount.nix
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
    # Custom tools
    auto-mount

    #System:
    alejandra
    btrfs-progs
    efitools
    extest
    git
    git-filter-repo
    home-manager
    htop
    jq
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji
    oh-my-zsh
    rsync
    rustdesk
    sbctl
    steam
    udisks
    util-linux
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

  programs.steam = lib.mkForce {
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
  services.desktopManager.plasma6.enable = true;
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

  # # Enable automounting of removable media
  # services.udisks2.enable = true;
  # services.devmon.enable = true;
  # services.gvfs.enable = true;
  # environment.variables.GIO_EXTRA_MODULES = lib.mkForce ["${pkgs.gvfs}/lib/gio/modules"];

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

  users.users.lillian.extraGroups = ["decky" "tss" "input"];

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

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  # tss group has access to TPM devices

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.initrd.systemd.enable = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.consoleLogLevel = 0;
  boot.kernelParams = ["quiet" "udev.log_priority=0" "fbcon=vc:2-6" "console=tty0"];
  boot.plymouth.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
