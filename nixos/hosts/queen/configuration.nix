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
    inputs.home-manager.nixosModules.home-manager
    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hardware-configuration.nix

    # Import locale settings
    ../../shared/locale/configuration.nix

    # Import shared packages
    ../../shared/packages/configuration.nix

    #../../server/package-configs/akkoma/configuration.nix
    ../../server/package-configs/forgejo/configuration.nix
    ../../server/package-configs/gotosocial/configuration.nix
    ../../server/package-configs/mail-server/configuration.nix
    ../../server/package-configs/nextcloud/configuration.nix
    ../../server/package-configs/postgres/configuration.nix
    ../../server/package-configs/postgres/upgrade.nix
    ../../server/package-configs/roundcube/configuration.nix
    ../../server/package-configs/jellyfin/configuration.nix
    ../../server/package-configs/ombi/configuration.nix
    ../../server/package-configs/aria2/configuration.nix
    ../../server/package-configs/conduit/configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "";
  services.openssh.enable = true;

  nixpkgs = {
    # You can add overlays here
    overlays = [
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
  sops.age.keyFile = ../../../../../var/secrets/keys.txt;

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
    aria2
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    nextcloud28
    nginx
    onlyoffice-documentserver
    postgresql_16
    python3
    rabbitmq-server
    roundcube
    roundcubePlugins.contextmenu
    roundcubePlugins.carddav
    roundcubePlugins.custom_from
    roundcubePlugins.persistent_login
    roundcubePlugins.thunderbird_labels
    youtube-dl
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "ens18";

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [22 80 443];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "letsencrypt@gladtherescake.eu";
  };

  # users.groups.virtualMail = {};

  users.users = {
    lillian = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGatnsrKMoZSW24Lw4meb6BAgHgeyN/8rUib4nZVT+CB lillian@EDI"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
      ];
      isNormalUser = true;
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf"];
      shell = pkgs.zsh;
    };
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/queen/queen-Lillian.nix;
    };
  };

  networking.hostName = "queen";

  boot.loader.grub.enable = true;
  boot.loader.grub.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
