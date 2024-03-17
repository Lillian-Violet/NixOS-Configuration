{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # Enable starship
  programs.starship = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      cd = "z";
      code = "codium ./";
      lh = "ls -lah";
    };
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "sha256-Z6EYQdasvpl1P78poj9efnnLj7QQg13Me8x1Ryyw+dM=";
        };
      }
    ];
    autosuggestion.enable = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    #zsh-abbr.enable = true;
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
        "z"
      ];
      theme = "jtriley";
    };
  };
}
