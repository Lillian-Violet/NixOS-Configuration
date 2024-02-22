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

    ./armv7l.nix
    ./hardware-configuration.nix

    # Import locale settings
    ../../shared/locale

    # Import shared packages
    ../../shared/packages
  ];

  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 5;
  boot.loader.grub.enable = false;
  boot.tmp.cleanOnBoot = true;

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

  sops.defaultSopsFile = ./secrets/sops.yaml;

  sops.secrets."wireless.env".mode = "0440";
  sops.secrets."wireless.env".owner = config.users.users.root.name;

  environment.systemPackages = with pkgs; [
    age
    git
    htop
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

  networking.wireless.enable = true;
  networking.wireless.environmentFile = config.sops.secrets."wireless.env".path;
  networking.wireless.networks."KPNAA6306" = {
    hidden = true;
    auth = ''
      key_mgmt=WPA-PSK
      password="@PSK_HOME@"
    '';
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

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/wheatley;
    };
  };

  networking.hostName = "wheatley"; # Define your hostname

  networking.wireless.interfaces = ["enu1u1"];

  # powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.cpufreq.max = 648000;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "unstable"; # Did you read the comment?
}
