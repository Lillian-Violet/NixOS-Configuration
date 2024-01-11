# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager

    ./hardware-configuration.nix
    ../../shared/locale/configuration.nix
  ];

  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.grub.enable = false;

  # boot.extraModulePackages = [
  #   (pkgs.callPackage ./rtl8189es.nix {
  #     kernel = config.boot.kernelPackages.kernel;
  #   })
  # ];
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

  environment.systemPackages = with pkgs; [
    age
    git
  ];

  boot.kernelParams = [
    "console=ttyS0,115200n8"
  ];

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:2024.01.0";
    ports = [
      "53:53/udp"
      "53:53/tcp"
      "80:80/tcp"
    ];
    environment = {
      TZ = config.time.timeZone;
      WEB_PORT = "80";
      WEBPASSWORD = "toor";
      #VIRTUAL_HOST = "192.168.1.114";
      PIHOLE_DNS_ = "127.0.0.1#5353";
      REV_SERVER = "true";
      REV_SERVER_DOMAIN = "router.lan";
      REV_SERVER_TARGET = "192.168.1.1";
      REV_SERVER_CIDR = "192.168.1.0/16";
      DNSMASQ_LISTENING = "local";
    };
    extraOptions = [
      "--network=host"
    ];
  };

  systemd.services."podman-pihole".postStart = ''
    sleep 300s

    podman exec pihole pihole -a adlist add "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt"
    podman exec pihole pihole -a adlist add "https://adaway.org/hosts.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/AdguardDNS.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Admiral.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Easylist.txt"
    podman exec pihole pihole -a adlist add "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/jdlingyu/ad-wars/master/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/static/w3kbl.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Shalla-mal.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt"
    podman exec pihole pihole -a adlist add "https://someonewhocares.org/hosts/zero/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/HorusTeknoloji/TR-PhishingList/master/url-lists.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Easyprivacy.txt"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Prigent-Ads.txt"
    podman exec pihole pihole -a adlist add "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-blocklist.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt"
    podman exec pihole pihole -a adlist add "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt"
    podman exec pihole pihole -a adlist add "https://hostfiles.frogeye.fr/multiparty-trackers-hosts.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/android-tracking.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/SmartTV.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/Perflyst/PiHoleBlocklist/master/AmazonFireTV.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/RooneyMcNibNug/pihole-stuff/master/SNAFU.txt"
    podman exec pihole pihole -a adlist add "https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt"
    podman exec pihole pihole -a adlist add "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt"
    podman exec pihole pihole -a adlist add "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt"
    podman exec pihole pihole -a adlist add "https://phishing.army/download/phishing_army_blocklist_extended.txt"
    podman exec pihole pihole -a adlist add "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts"
    podman exec pihole pihole -a adlist add "https://urlhaus.abuse.ch/downloads/hostfile/"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Prigent-Malware.txt"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn/hosts"
    podman exec pihole pihole -a adlist add "https://raw.githubusercontent.com/chadmayfield/my-pihole-blocklists/master/lists/pi_blocklist_porn_all.list"
    podman exec pihole pihole -a adlist add "https://v.firebog.net/hosts/Prigent-Crypto.txt"
    podman exec pihole pihole -a adlist add "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser"

    podman exec pihole pihole -g
  '';

  services.openssh = {
    enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [22 80 443];

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  programs.zsh = {
    enable = true;
  };

  programs.git = {
    enable = true;
  };

  users.users = {
    lillian = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYgErCnva8fvLvsmTMC6dHJp2Fvwja0BYL8K/58ugDxNA0PVGj5PpEMar5yhi4AFGGYL4EgD75tRgI/WQU87ZiKjJ6HFIhgX9curncB2kIJ0JoA+FIQMNOT72GFuhjcO4svanrobsMrRmcn193suXY/N6m6F+3pitxBfHPWuPKKjlZqVBzpqCdz9pXoGOk48OSYv7Zyw8roVsUw3fqJqs68LRLM/winWVhVSPabXGyX7PAAW51Nbv6M64REs+V1a+wGvK5sGhRy7lIBAIuD22tuL4/PZojST1hasKN+7cSp7F1QTi4u0yeQ2+gIclQNuhfvghzl6zcVEpOycFouSIJaJjo8jyuHkbm4I2XfALVTFHe7sLpYNNS7Mf6E6i5rHvAvtXI4UBx/LjgPOj7RWZFaotxQRk1D+N0y2xNrO4ft6mS+hrJ/+ybp1XTGdtlkpUDKjiTZkV7Z4fq9J0jtijvtxRfcPhjia50IIHtZ28wVBMCCwYzh5pR15F/XbvKCc= lillian@EDI"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
      ];
      isNormalUser = true;
      extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf"];
      shell = pkgs.zsh;
    };
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {
      # Import your home-manager configuration
      lillian = import ../../../home-manager/hosts/wheatley/wheatley-Lillian.nix;
    };
  };

  networking.hostName = "wheatley"; # Define your hostname

  networking.wireless.interfaces = ["wlan0"];

  # powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.cpufreq.max = 648000;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "unstable"; # Did you read the comment?
}
