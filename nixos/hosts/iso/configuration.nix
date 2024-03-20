{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  nixpkgs-stable,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example
    # outputs.nixosModules.contabo.wan
    inputs.home-manager.nixosModules.home-manager
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.defaults

    # Import shared settings
    ../../shared
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "";
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  #Set up sops config, and configure where the keyfile is, then set the mode for the unencrypted keys
  sops.defaultSopsFile = ./secrets/sops.yaml;

  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    # Custom tools
    dvd
    dvt
    servo
    restart
    install-nix

    # System tools
    aha
    direnv
    efitools
    git-filter-repo
    gnupg
    pciutils
    sbctl
    tpm2-tools
    tpm2-tss
    waydroid
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
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Contabo ipv6 nameservers: "2a02:c207::1:53" "2a02:c207::2:53"

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [22];

  programs.kdeconnect.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "terminate:ctrl_alt_bksp,compose:caps_toggle";
  };

  # Enable bluetooth hardware
  hardware.bluetooth.enable = true;

  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true; # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
  security.tpm2.tctiEnvironment.enable = true; # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  users.users.lillian.extraGroups = ["tss"]; # tss group has access to TPM devices

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  programs.git = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  # kde power settings do not turn off screen
  systemd = {
    services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/iso;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
