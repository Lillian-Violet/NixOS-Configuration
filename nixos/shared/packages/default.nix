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

    # System tools
    age
    alejandra
    git
    git-filter-repo
    home-manager
    htop
    libnotify
    neofetch
    oh-my-zsh
    rsync
    spacevim
    wget
    zsh
    tldr

    # System libraries
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];
}
