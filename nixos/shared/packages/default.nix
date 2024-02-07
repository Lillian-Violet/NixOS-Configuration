{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # System tools
    age
    alejandra
    git
    git-filter-repo
    home-manager
    htop
    neofetch
    oh-my-zsh
    rsync
    spacevim
    wget
    zsh
    tldr

    # System libraries
    noto-fonts
    noto-fonts-emoji-blob-bin
    noto-fonts-emoji
  ];
}
