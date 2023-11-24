{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.3.0/nixos-mailserver-v2.3.0.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "0lpz08qviccvpfws2nm83n7m2r8add2wvfg9bljx9yxx8107r919";
    })
  ];

  users.users = {
    virtualMail = {
      isSystemUser = true;
      isNormalUser = false;
      group = "virtualMail";
    };
  };
  mailserver = {
    enable = true;
    fqdn = "mail.gladtherescake.eu";
    domains = ["nextcloud.gladtherescake.eu"];

    loginAccounts = {
      "no-reply@nextcloud.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
        aliases = ["postmaster@nextcloud.gladtherescake.eu" "abuse@nextcloud.gladtherescake.eu" "security@nextcloud.gladtherescake.eu"];
      };
    };
  };
}
