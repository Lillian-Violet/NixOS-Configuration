{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: let
  # You'll need to edit these values
  # The hostname that will appear in your user and room IDs
  server_name = "matrix.gladtherescake.eu";

  # An admin email for TLS certificate notifications
  admin_email = "letsencrypt@gladtherescake.eu";

  # These ones you can leave alone

  # Build a dervation that stores the content of `${server_name}/.well-known/matrix/server`
  well_known_server = pkgs.writeText "well-known-matrix-server" ''
    {
      "m.server": "${server_name}"
    }
  '';

  # Build a dervation that stores the content of `${server_name}/.well-known/matrix/client`
  well_known_client = pkgs.writeText "well-known-matrix-client" ''
    {
      "m.homeserver": {
        "base_url": "https://${server_name}"
      }
    }
  '';
in {
  # Configure Conduit itself
  services.matrix-conduit = {
    enable = true;

    # This causes NixOS to use the flake defined in this repository instead of
    # the build of Conduit built into nixpkgs.
    package = inputs.conduit.packages.${pkgs.system}.default;

    settings.global = {
      inherit server_name;
      database_backend = "rocksdb";
      allow_registration = false;
      turn_uris = ["turn:turn.gladtherescake.eu.url?transport=udp" "turn:turn.gladtherescake.eu?transport=tcp"];
      turn_secret = "cPKWEn4Fo5TAJoE7iX3xeVOaMVE4afeRN1iRGWYfbkWbkaZMxTpnmazHyH6c6yXT";
    };
  };

  # Configure automated TLS acquisition/renewal
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = admin_email;
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
      "${server_name}" = {
        forceSSL = true;
        enableACME = true;

        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
          {
            addr = "[::]";
            port = 443;
            ssl = true;
          }
          {
            addr = "0.0.0.0";
            port = 8448;
            ssl = true;
          }
          {
            addr = "[::]";
            port = 8448;
            ssl = true;
          }
        ];

        locations."/_matrix/" = {
          proxyPass = "http://backend_conduit";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_buffering off;
          '';
        };
        locations."=/.well-known/matrix/server" = {
          # Use the contents of the derivation built previously
          alias = "${well_known_server}";

          extraConfig = ''
            # Set the header since by default NGINX thinks it's just bytes
            default_type application/json;
          '';
        };

        locations."=/.well-known/matrix/client" = {
          # Use the contents of the derivation built previously
          alias = "${well_known_client}";

          extraConfig = ''
            # Set the header since by default NGINX thinks it's just bytes
            default_type application/json;

            # https://matrix.org/docs/spec/client_server/r0.4.0#web-browser-clients
            add_header Access-Control-Allow-Origin "*";
          '';
        };

        extraConfig = ''
          merge_slashes off;
        '';
      };
    };

    upstreams = {
      "backend_conduit" = {
        servers = {
          "[::1]:${toString config.services.matrix-conduit.settings.global.port}" = {};
        };
      };
    };
  };

  # Open firewall ports for HTTP, HTTPS, and Matrix federation
  networking.firewall.allowedTCPPorts = [80 443 8448];
  networking.firewall.allowedUDPPorts = [80 443 8448];
}
