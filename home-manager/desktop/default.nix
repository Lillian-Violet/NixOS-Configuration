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
    ../package-configs/zsh.nix
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

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];

  home.packages = with pkgs; [
    # Coding:
    direnv
    git
    ruff
    kate

    # Chat applications:
    element-desktop
    signal-desktop
    webcord-vencord

    # Gaming:
    prismlauncher
    steam

    # Multimedia:
    freetube
    vlc

    # Office applications:
    onlyoffice-bin
    teams-for-linux
    gimp-with-plugins
    thunderbird

    # System tools:
    rage
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
    librewolf
    ungoogled-chromium
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      arrterian.nix-env-selector
      #ban.spellright
      #charliermarsh.ruff
      dracula-theme.theme-dracula
      eamodio.gitlens
      github.vscode-pull-request-github
      jnoortheen.nix-ide
      kamadorueda.alejandra
      mkhl.direnv
      ms-toolsai.jupyter
      ms-pyright.pyright
      ms-python.black-formatter
      #ms-python.python
      ms-python.vscode-pylance
      #ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      oderwat.indent-rainbow
      redhat.java
      rust-lang.rust-analyzer
      yzhang.markdown-all-in-one
    ];
  };

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
    ];
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "git@lillianviolet.dev";
    userName = "Lillian-Violet";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
    ignores = [
      "*.direnv"
      "*.vscode"
      ".envrc"
    ];
  };

  programs.gpg.enable = true;
  programs.gpg.settings = {
    default-key = "0d43 5407 034c 2ad9 2d42 799d 280e 061d ff60 0f0d";
    default-recipient-self = true;
    auto-key-locate = "local,wkd,keyserver";
    keyserver = "hkps://keys.openpgp.org";
    auto-key-retrieve = true;
    auto-key-import = true;
    keyserver-options = "honor-keyserver-url";
    no-autostart = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
