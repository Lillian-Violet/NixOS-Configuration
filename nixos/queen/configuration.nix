{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
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
    ./nextcloud.nix
    ./mail-server.nix
    ./akkoma.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = false;
  networking.domain = "";
  services.openssh.enable = true;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

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
  sops.defaultSopsFile = ../../secrets/queen-Lillian.yaml;
  sops.age.keyFile = ./keys.txt;
  sops.secrets."nextcloudadmin".mode = "0440";
  sops.secrets."nextcloudadmin".owner = config.users.users.nextcloud.name;
  sops.secrets."nextclouddb".mode = "0440";
  sops.secrets."nextclouddb".owner = config.users.users.nextcloud.name;
  sops.secrets."local.json".mode = "0440";
  sops.secrets."local.json".owner = config.users.users.onlyoffice.name;
  sops.secrets."mailpass".mode = "0440";
  sops.secrets."mailpass".owner = config.users.users.virtualMail.name;
  sops.secrets."releaseCookie".mode = "0440";
  sops.secrets."releaseCookie".owner = config.users.users.akkoma.name;

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
    age
    fzf
    docker
    docker-compose
    git
    alejandra
    exiftool
    imagemagick
    ffmpeg
    aria2
    git-filter-repo
    home-manager
    nextcloud27
    nginx
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji
    oh-my-zsh
    onlyoffice-documentserver
    postgresql_15
    postgresql15Packages.rum
    python3
    rsync
    rabbitmq-server
    youtube-dl
    wget
    zsh
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [80 443 1443];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };

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

  users.groups.mssql = {};

  users.groups.virtualMail = {};

  users.users = {
    lillian = {
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYgErCnva8fvLvsmTMC6dHJp2Fvwja0BYL8K/58ugDxNA0PVGj5PpEMar5yhi4AFGGYL4EgD75tRgI/WQU87ZiKjJ6HFIhgX9curncB2kIJ0JoA+FIQMNOT72GFuhjcO4svanrobsMrRmcn193suXY/N6m6F+3pitxBfHPWuPKKjlZqVBzpqCdz9pXoGOk48OSYv7Zyw8roVsUw3fqJqs68LRLM/winWVhVSPabXGyX7PAAW51Nbv6M64REs+V1a+wGvK5sGhRy7lIBAIuD22tuL4/PZojST1hasKN+7cSp7F1QTi4u0yeQ2+gIclQNuhfvghzl6zcVEpOycFouSIJaJjo8jyuHkbm4I2XfALVTFHe7sLpYNNS7Mf6E6i5rHvAvtXI4UBx/LjgPOj7RWZFaotxQRk1D+N0y2xNrO4ft6mS+hrJ/+ybp1XTGdtlkpUDKjiTZkV7Z4fq9J0jtijvtxRfcPhjia50IIHtZ28wVBMCCwYzh5pR15F/XbvKCc= lillian@EDI"];
      isNormalUser = true;
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf"];
      shell = pkgs.zsh;
    };

    nextcloud.extraGroups = [config.users.groups.keys.name "aria2" "onlyoffice"];
    mssql = {
      isSystemUser = true;
      group = "mssql";
    };

    virtualMail = {
      isSystemUser = true;
      isNormalUser = false;
      group = "virtualMail";
    };
  };

  virtualisation.oci-containers.containers = {
    mssql = {
      image = "mcr.microsoft.com/mssql/server:2022-latest";
      ports = ["1433:1433"];
      environment = {
        "ACCEPT_EULA" = "Y";
        "MSSQL_SA_PASSWORD" = "EbKihNUHg6S$V$qchADFmw!JCm##toc3";
      };
      volumes = ["/home/lillian/docker/mssql:/data"];
    };
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../home-manager/queen-Lillian.nix;
    };
  };

  networking.hostName = "queen";

  boot.loader.grub.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
