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
    ./program-configs/zsh.nix
  ];
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
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "lillian";
    homeDirectory = "/home/lillian";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  home.packages = with pkgs; [
    # Coding:
    azuredatastudio
    git
    kate

    # Chat applications:
    element-desktop
    signal-desktop
    webcord

    # Gaming:
    prismlauncher
    steam

    # Multimedia:
    freetube
    obs-studio
    vlc

    # Office applications:
    onlyoffice-bin
    teams-for-linux

    # System tools:
    rage
    bitwarden
    discover
    flameshot
    fzf
    nextcloud-client
    nitrokey-app
    protonvpn-gui
    sops
    virtualbox
    watchmate
    qbittorrent
    zsh

    # Web browsing:
    firefox
    ungoogled-chromium
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      arrterian.nix-env-selector
      ban.spellright
      dracula-theme.theme-dracula
      eamodio.gitlens
      github.vscode-pull-request-github
      jnoortheen.nix-ide
      kamadorueda.alejandra
      ms-toolsai.jupyter
      ms-pyright.pyright
      #ms-python.python
      ms-python.vscode-pylance
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      oderwat.indent-rainbow
      rust-lang.rust-analyzer
      yzhang.markdown-all-in-one
    ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "git@gladtherescake.eu";
    userName = "Lillian-Violet";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
