{
  sops.secrets."coturn-auth-secret".mode = "0440";
  sops.secrets."coturn-auth-secret".owner = config.users.users.coturn.name;
  services.coturn = {
    enable = true;
    lt-cred-mech = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets."coturn-auth-secret".path;
    realm = "turn.gladtherescake.eu";
    relay-ips = [
      "62.171.160.195"
    ];
    no-tcp-relay = true;
    extraConfig = "
      cipher-list=\"HIGH\"
      no-loopback-peers
      no-multicast-peers
    ";
    secure-stun = true;
    cert = "/var/lib/acme/turn.gladtherescake.eu/fullchain.pem";
    pkey = "/var/lib/acme/turn.gladtherescake.eu/key.pem";
    min-port = 49152;
    max-port = 49999;
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowPing = false;
    allowedTCPPorts = [
      5349 # STUN tls
      5350 # STUN tls alt
      80 # http
      443 # https
    ];
    allowedUDPPortRanges = [
      {
        from = 49152;
        to = 49999;
      } # TURN relay
    ];
  };

  # setup certs
  services.nginx = {
    enable = true;
    virtualHosts = {
      "turn.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  # share certs with coturn and restart on renewal
  security.acme.certs = {
    "turn.gladtherescake.eu" = {
      group = "turnserver";
      allowKeysForGroup = true;
      postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
    };
  };
}
