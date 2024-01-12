# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ../../shared/locale/configuration.nix
  ];

  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub.enable = false;
  boot.cleanTmpDir = true;

  # boot.extraModulePackages = [
  #   (pkgs.callPackage ./rtl8189es.nix {
  #     kernel = config.boot.kernelPackages.kernel;
  #   })
  # ];
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

  environment.systemPackages = with pkgs; [
    age
    git
  ];

  boot.kernelParams = [
    "console=ttyS0,115200n8"
  ];

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

  services.pihole = {
    enable = true;
    hostConfig = {
      # define the service user for running the rootless Pi-hole container
      user = "pihole";
      enableLingeringForUser = true;

      # we want to persist change to the Pi-hole configuration & logs across service restarts
      # check the option descriptions for more information
      persistVolumes = true;

      # expose DNS & the web interface on unpriviledged ports on all IP addresses of the host
      # check the option descriptions for more information
      dnsPort = 5335;
      webProt = 8080;
    };
    piholeConfig.ftl = {
      # assuming that the host has this (fixed) IP and should resolve "pi.hole" to this address
      # check the option description & the FTLDNS documentation for more information
      LOCAL_IPV4 = "192.168.0.2";
    };
    piholeCOnfig.web = {
      virtualHost = "pi.hole";
      password = "password";
    };
  };

  networking.firewall.enable = true;

  networking.firewall = {
    allowedTCPPorts = [22 80 443 5335 8080];
    allowedUDPPorts = [5335];
  };
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

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
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf"];
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/wheatley/wheatley-Lillian.nix;
    };
  };

  networking.hostName = "wheatley"; # Define your hostname

  networking.wireless.interfaces = ["wlan0"];

  # powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.cpufreq.max = 648000;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "unstable"; # Did you read the comment?
}
