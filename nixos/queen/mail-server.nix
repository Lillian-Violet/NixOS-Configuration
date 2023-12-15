{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/24128c3052090311688b09a400aa408ba61c6ee5/nixos-mailserver-A-COMMIT-ID.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/24128c3052090311688b09a400aa408ba61c6ee5/nixos-mailserver-A-COMMIT-ID.tar.gz" --unpack
      sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

  sops.secrets."mailpass".mode = "0440";
  sops.secrets."mailpass".owner = config.users.users.virtualMail.name;

  users.users = {
    virtualMail = {
      isSystemUser = true;
      isNormalUser = false;
      group = "virtualMail";
    };
  };

  mailserver = {
    enable = true;
    enableImap = true;
    enableSubmission = true;
    fqdn = "mail.gladtherescake.eu";
    domains = [
      "nextcloud.gladtherescake.eu"
      "akkoma.gladtherescake.eu"
      "social.gladtherescake.eu"
    ];

    loginAccounts = {
      "no-reply@nextcloud.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
      "no-reply@akkoma.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
      "no-reply@social.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
    };

    rejectRecipients = [
      "no-reply@nextcloud.gladtherescake.eu"
      "no-reply@akkoma.gladtherescake.eu"
      "no-reply@social.gladtherescake.eu"
    ];
    certificateScheme = "acme-nginx";
  };

  mailserver = {
    enable = true;
    enableImap = true;
    enableSubmission = true;
    fqdn = "mail.lillianviolet.dev";
    domains = [
      "lillianviolet.dev"
    ];

    loginAccounts = {
      "info@lillianviolet.dev" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
        aliases = [
          "@lillianviolet.dev"
        ];
        catchAll = [
          "lillianviolet.dev"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
