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
  ];

  home.packages = with pkgs; [
    #Chat:
    webcord-vencord

    #Gaming:
    prismlauncher

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

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
