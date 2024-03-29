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
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hardware-configuration.nix

    # Import shared settings
    ../../shared

    # Import server settings
    ../../server
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "";
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
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

  environment.systemPackages = with pkgs; [
    akkoma
    fzf
    matrix-conduit
    docker
    docker-compose
    gitea
    gotosocial
    alejandra
    exiftool
    imagemagick
    ffmpeg
    #aria2
    #jellyfin
    #jellyfin-web
    #jellyfin-ffmpeg
    nextcloud28
    nginx
    onlyoffice-documentserver
    postgresql_16
    python3
    python311Packages.nbconvert
    jupyter
    rabbitmq-server
    roundcube
    roundcubePlugins.contextmenu
    roundcubePlugins.carddav
    roundcubePlugins.custom_from
    roundcubePlugins.persistent_login
    roundcubePlugins.thunderbird_labels
    youtube-dl
    sqlite
    rocksdb
  ];

  # Create an auto-update systemd service that runs every day
  system.autoUpgrade = {
    flake = "git+https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git";
    dates = "daily";
    enable = true;
  };

  systemd.services.systemd-networkd.serviceConfig.Environment = "SYSTEMD_LOG_LEVEL=debug";
  # Enable networking
  networking.networkmanager.enable = true;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "ens18";
  networking.enableIPv6 = lib.mkForce true;
  networking.nameservers = ["1.1.1.1"];

  # Contabo ipv6 nameservers: "2a02:c207::1:53" "2a02:c207::2:53"

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = [
      22 # SSH
      5349 # STUN tls
      5350 # STUN tls alt
      80 # http
      443 # https
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 49999;
      } # TURN relay
    ];
  };

  # networking.useNetworkd = true;

  # networking.useDHCP = false;

  # modules.contabo.wan = {
  #   enable = true;
  #   macAddress = "00:50:56:43:01:e2"; # changeme
  #   ipAddresses = [
  #     "192.0.2.0/32"
  #     "2001:db8::1/64"
  #   ];
  # };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  programs.git = {
    enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@gladtherescake.eu";
  };

  # users.groups.virtualMail = {};

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/queen;
    };
  };

  networking.hostName = "queen";

  boot.loader.grub.enable = true;
  boot.loader.grub.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
