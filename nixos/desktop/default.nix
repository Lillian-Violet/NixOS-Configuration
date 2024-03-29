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
    # Import shared packages
    ../shared
  ];
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      #outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Custom tools
    dvd
    dvt
    servo
    restart

    # System tools
    aha
    bcachefs-tools
    direnv
    git-filter-repo
    gnupg
    pciutils
    podman
    podman-compose
    sbctl
    tpm2-tools
    tpm2-tss
    waydroid
    xwaylandvideobridge
    yubikey-personalization
    zsh

    # KDE/QT
    krunner-translator
    kdePackages.discover
    kdePackages.kcalc
    kdePackages.kdepim-addons
    kdePackages.kirigami
    kdePackages.kdeconnect-kde
    # kdePackages.krunner-ssh
    # kdePackages.krunner-symbols
    kdePackages.packagekit-qt
    kdePackages.plasma-pa
    kdePackages.sddm-kcm
    kdePackages.dolphin-plugins
    libportal-qt5
    libportal

    # User tools
    noisetorch
    qjackctl
    wireplumber
    rustdesk
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
  services.xserver.displayManager.sddm.wayland.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.displayManager.defaultSession = "plasma";
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
    jack.enable = true;
    wireplumber.enable = true;
  };

  programs.noisetorch = {
    enable = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.lillian.extraGroups = ["tss"]; # tss group has access to TPM devices

  # FIXME: re-enable virtual camera loopback when it build again.
  boot.bootspec.enable = true;
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
  boot.supportedFilesystems = ["bcachefs"];
  # boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];
  boot.kernelModules = [
    # Virtual Camera
    # "v4l2loopback"
    # Virtual Microphone, built-in
    "snd-aloop"
  ];
  # Set initial kernel module settings
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    # options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
}
