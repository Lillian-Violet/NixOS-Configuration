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

  mailserver = {
    enable = true;
    enableImap = true;
    fqdn = "mail.gladtherescake.eu";
    domains = ["nextcloud.gladtherescake.eu"];

    loginAccounts = {
      "no-reply@nextcloud.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
    };
    rejectRecipients = ["no-reply@nextcloud.gladtherescake.eu"];
    certificateScheme = "acme-nginx";
  };
}
