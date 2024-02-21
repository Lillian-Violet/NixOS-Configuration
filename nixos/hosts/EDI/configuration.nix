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
  # You can import other NixOS modules here
  imports = [
    # Import home-manager's NixOS module
    inputs.home-manager.nixosModules.home-manager
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    ../../desktop

    ../../../disko/EDI

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  sops.defaultSopsFile = ./secrets/sops.yaml;
  sops.age.keyFile = ../../../../../../var/secrets/keys.txt;

  sops.secrets."lillian-password".neededForUsers = true;

  users.users.lillian = {
    hashedPasswordFile = config.sops.secrets."lillian-password".path;
    extraGroups = ["docker"];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/EDI;
    };
  };

  environment.systemPackages = with pkgs; [
    podman
    podman-compose
    sbctl
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  networking.hostName = "EDI";

  boot.bootspec.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = ["bcachefs"];

  # Lanzaboote currently replaces the systemd-boot module.
  # This setting is usually set to true in configuration.nix
  # generated at installation time. So we force it to false
  # for now.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # Enable bluetooth hardware
  hardware.bluetooth.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "unstable";
}
