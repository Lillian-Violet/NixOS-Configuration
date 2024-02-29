{
  pkgs,
  config,
  lib,
  flake-inputs,
  ...
}: let
  inherit (lib.strings) concatMapStringsSep;

  cfg = config.services.matrix-conduit;
  domain = "matrix.gladtherescake.eu";
  turn-realm = "turn.gladtherescake.eu";
in {
  services.matrix-conduit = {
    enable = true;
    package = flake-inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.matrix-conduit;
    settings.global = {
      address = "127.0.0.1";
      server_name = domain;
      database_backend = "rocksdb";

      turn_uris = let
        address = "${config.services.coturn.realm}:${toString config.services.coturn.listening-port}";
        tls-address = "${config.services.coturn.realm}:${toString config.services.coturn.tls-listening-port}";
      in [
        "turn:${address}?transport=udp"
        "turn:${address}?transport=tcp"
        "turns:${tls-address}?transport=udp"
        "turns:${tls-address}?transport=tcp"
      ];
    };
  };

  systemd.services.heisenbridge = let
    replaceSecretBin = "${pkgs.replace-secret}/bin/replace-secret";
    registrationFile = builtins.toFile "heisenbridge-registration.yaml" (builtins.toJSON {
      id = "heisenbridge";
      url = "http://127.0.0.1:9898";
      as_token = "@AS_TOKEN@";
      hs_token = "@HS_TOKEN@";
      rate_limited = false;
      sender_localpart = "heisenbridge";
      namespaces = {
        users = [
          {
            regex = "@irc_.*";
            exclusive = true;
          }
          {
            regex = "@heisenbridge:.*";
            exclusive = true;
          }
        ];
        aliases = [];
        rooms = [];
      };
    });

    # TODO(tlater): Starting with systemd 253 it will become possible
    # to do the credential setup as part of ExecStartPre/preStart
    # instead.
    #
    # This will also make it possible to actually set caps on the
    # heisenbridge process using systemd, so that we can run the
    # identd process.
    execScript = pkgs.writeShellScript "heisenbridge" ''
      cp ${registrationFile} "$RUNTIME_DIRECTORY/heisenbridge-registration.yaml"
      chmod 600 $RUNTIME_DIRECTORY/heisenbridge-registration.yaml
      ${replaceSecretBin} '@AS_TOKEN@' "$CREDENTIALS_DIRECTORY/heisenbridge_as-token" "$RUNTIME_DIRECTORY/heisenbridge-registration.yaml"
      ${replaceSecretBin} '@HS_TOKEN@' "$CREDENTIALS_DIRECTORY/heisenbridge_hs-token" "$RUNTIME_DIRECTORY/heisenbridge-registration.yaml"
      chmod 400 $RUNTIME_DIRECTORY/heisenbridge-registration.yaml

      ${pkgs.heisenbridge}/bin/heisenbridge \
          --config $RUNTIME_DIRECTORY/heisenbridge-registration.yaml \
          --owner @tlater:matrix.tlater.net \
          'http://localhost:${toString cfg.settings.global.port}'
    '';
  in {
    description = "Matrix<->IRC bridge";
    wantedBy = ["multi-user.target"];
    after = ["conduit.service"];

    serviceConfig = {
      Type = "simple";

      LoadCredential = "heisenbridge:/run/secrets/heisenbridge";

      ExecStart = execScript;

      DynamicUser = true;
      RuntimeDirectory = "heisenbridge";
      RuntimeDirectoryMode = "0700";

      RestrictNamespaces = true;
      PrivateUsers = true;
      ProtectHostname = true;
      ProtectClock = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectKernelLogs = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = ["AF_INET AF_INET6"];
      LockPersonality = true;
      RestrictRealtime = true;
      ProtectProc = "invisible";
      ProcSubset = "pid";
      UMask = 0077;

      # For the identd port
      # CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
      # AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
    };
  };

  # Pass in the TURN secret via EnvironmentFile, not supported by
  # upstream module currently.
  #
  # See also https://gitlab.com/famedly/conduit/-/issues/314
  systemd.services.conduit.serviceConfig.EnvironmentFile = config.sops.secrets."turn/env".path;

  services.coturn = {
    enable = true;
    no-cli = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."turn/secret".path;
    realm = turn-realm;
    relay-ips = [
      "178.79.137.55"
    ];

    # SSL config
    #
    # TODO(tlater): Switch to letsencrypt once google fix:
    #  https://github.com/vector-im/element-android/issues/1533
    pkey = config.sops.secrets."turn/ssl-key".path;
    cert = config.sops.secrets."turn/ssl-cert".path;

    # Based on suggestions from
    # https://github.com/matrix-org/synapse/blob/develop/docs/turn-howto.md
    # and
    # https://www.foxypossibilities.com/2018/05/19/setting-up-a-turn-sever-for-matrix-on-nixos/
    no-tcp-relay = true;
    secure-stun = true;
    extraConfig = ''
      # Deny various local IP ranges, see
      # https://www.rtcsec.com/article/cve-2020-26262-bypass-of-coturns-access-control-protection/
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255 denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff

      # *Allow* any IP addresses that we explicitly set as relay IPs
      ${concatMapStringsSep "\n" (ip: "allowed-peer-ip=${ip}") config.services.coturn.relay-ips}

      # Various other security settings
      no-tlsv1
      no-tlsv1_1

      # Monitoring
      prometheus
    '';
  };

  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;

    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
      }
      {
        addr = "[::0]";
        port = 80;
      }
      {
        addr = "0.0.0.0";
        port = 443;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 443;
        ssl = true;
      }
      {
        addr = "0.0.0.0";
        port = 8448;
        ssl = true;
      }
      {
        addr = "[::0]";
        port = 8448;
        ssl = true;
      }
    ];

    forceSSL = true;
    extraConfig = ''
      merge_slashes off;
      access_log /var/log/nginx/${domain}/access.log upstream_time;
    '';

    locations = {
      "/_matrix" = {
        proxyPass = "http://${cfg.settings.global.address}:${toString cfg.settings.global.port}";
        # Recommended by conduit
        extraConfig = ''
          proxy_buffering off;
        '';
      };

      # Add Element X support
      # TODO(tlater): Remove when no longer required: https://github.com/vector-im/element-x-android/issues/1085
      "=/.well-known/matrix/client" = {
        alias = pkgs.writeText "well-known-matrix-client" (builtins.toJSON {
          "m.homeserver".base_url = "https://${domain}";
          "org.matrix.msc3575.proxy".url = "https://${domain}";
        });

        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin "*";
        '';
      };
    };
  };

  # services.backups.conduit = {
  #   user = "root";
  #   paths = [
  #     "/var/lib/private/matrix-conduit/"
  #   ];
  #   # Other services store their data in conduit, so no other services
  #   # need to be shut down currently.
  #   pauseServices = ["conduit.service"];
  # };
}
