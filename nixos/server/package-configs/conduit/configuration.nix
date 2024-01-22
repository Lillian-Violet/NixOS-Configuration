{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  # You'll need to edit these values
  # The hostname that will appear in your user and room IDs
  server_name = "matrix.gladtherescake.eu";

  # The hostname that Conduit actually runs on
  #
  # This can be the same as `server_name` if you want. This is only necessary
  # when Conduit is running on a different machine than the one hosting your
  # root domain. This configuration also assumes this is all running on a single
  # machine, some tweaks will need to be made if this is not the case.
  matrix_hostname = "${server_name}";
in {
  # Configure Conduit itself
  services.matrix-conduit = {
    enable = true;

    # This causes NixOS to use the flake defined in this repository instead of
    # the build of Conduit built into nixpkgs.
    package = pkgs.matrix-conduit;

    settings.global = {
      inherit server_name;
    };
  };

  # ACME data must be readable by the NGINX user
  users.users.nginx.extraGroups = [
    "acme"
  ];

  # Configure NGINX as a reverse proxy
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "${matrix_hostname}" = {
        forceSSL = true;
        enableACME = true;

        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
          {
            addr = "0.0.0.0";
            port = 8448;
            ssl = true;
          }
        ];
      };
    };
  };

  # Open firewall ports for HTTP, HTTPS, and Matrix federation
  networking.firewall.allowedTCPPorts = [80 443 8448];
  networking.firewall.allowedUDPPorts = [80 443 8448];
}
