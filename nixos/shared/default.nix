{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./locale
    ./packages
  ];
  sops.age.keyFile = ../../../../../../var/secrets/keys.txt;
  sops.secrets."lillian-password".neededForUsers = true;

  nix = {
    package = pkgs.nixFlakes;
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

  users.users.lillian = {
    isNormalUser = true;
    extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf" "docker"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets."lillian-password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGatnsrKMoZSW24Lw4meb6BAgHgeyN/8rUib4nZVT+CB lillian@EDI"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
    ];
  };

  programs.zsh = {
    enable = true;
  };

  # Enable completion of system packages by zsh
  environment.pathsToLink = ["/share/zsh"];

  environment.interactiveShellInit = ''
    alias cd='z'
  '';

  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = "*";
  };
}
