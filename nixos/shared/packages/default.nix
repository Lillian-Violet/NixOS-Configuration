{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
    ];
  };

  environment.systemPackages = with pkgs; [
    # Custom tools
    rebuild
    rebuild-no-inhibit
    install-nix
    update
    upgrade

    # System tools
    age
    alejandra
    e2fsprogs
    git
    git-filter-repo
    home-manager
    htop
    killall
    libnotify
    neofetch
    oh-my-zsh
    rsync
    helix
    wget
    zsh
    tldr

    # System libraries
  ];

  # fonts.packages = with pkgs; [
  #   noto-fonts
  #   noto-fonts-emoji-blob-bin
  #   noto-fonts-emoji
  #   (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono"];})
  # ];
}
