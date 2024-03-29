# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ../../package-configs/zsh.nix
    ../../desktop/plasma-desktop
  ];
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

  home = {
    username = "lillian";
    homeDirectory = "/home/lillian";
  };

  home.packages = with pkgs; [
    #Chat:
    webcord-vencord

    #Gaming:
    prismlauncher
    r2modman
    ryujinx

    # Multimedia:
    freetube
    obs-studio
    vlc

    # System tools:
    rage
    discover
    flameshot
    fzf
    nextcloud-client
    nitrokey-app
    protonvpn-gui
    sops
    watchmate
    qbittorrent
    zsh

    # Web browsing:
    librewolf
    ungoogled-chromium
  ];

  # # Automount services for user
  # programs.bashmount.enable = true;
  # services.udiskie = {
  #   enable = true;
  #   automount = true;
  #   notify = false;
  #   tray = "never";
  # };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "git@lillianviolet.dev";
    userName = "Lillian-Violet";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
