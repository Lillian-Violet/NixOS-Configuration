{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.matrix-conduit = {
    enable = true;
    settings.global = {
      allow_registration = true;
      server_name = "matrix.gladtherescake.eu";
      port = 6167;
    };
  };

  services.nginx = {
    virtualHosts = {
      "matrix.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:6167";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Open firewall ports for HTTP, HTTPS, and Matrix federation
  networking.firewall.allowedTCPPorts = [80 443 8448];
  networking.firewall.allowedUDPPorts = [80 443 8448];
}
