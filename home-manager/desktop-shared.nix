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

    # System tools:
    rage
    bitwarden
    discover
    flameshot
    fzf
    nextcloud-client
    nitrokey-app
    protonvpn-gui
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

  programs.zsh = {
    enable = true;
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.7.0";
          sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
        };
      }
    ];
    enableAutosuggestions = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    zsh-abbr.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "adb"
        "battery"
        "branch"
        "coffee"
        "colored-man-pages"
        "colorize"
        "command-not-found"
        "common-aliases"
        "compleat"
        "composer"
        "copypath"
        "copybuffer"
        "copyfile"
        "cp"
        "dirhistory"
        "dirpersist"
        "docker"
        "docker-compose"
        "extract"
        "fancy-ctrl-z"
        "fastfile"
        "frontend-search"
        "git-auto-fetch"
        "git-escape-magic"
        "git-extras"
        "git-flow"
        "github"
        "gitignore"
        "gnu-utils"
        "gpg-agent"
        "history"
        "history-substring-search"
        "isodate"
        "jsontools"
        "keychain"
        "man"
        "nanoc"
        "pip"
        "pipenv"
        "pyenv"
        "python"
        "rsync"
        "rvm"
        "screen"
        "sdk"
        "sfdx"
        "shell-proxy"
        "sudo"
        "systemadmin"
        "systemd"
        "themes"
        "urltools"
        "web-search"
        "zsh-interactive-cd"
        "zsh-navigation-tools"
      ];
      theme = "jtriley";
    };
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
