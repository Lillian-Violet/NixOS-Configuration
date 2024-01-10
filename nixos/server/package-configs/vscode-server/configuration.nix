{
  config,
  pkgs,
  lib,
  ...
}: {
  services.openvscode-server = {
    enable = true;
    port = 7773;
    telemetryLevel = "off";
    withoutConnectionToken = true;
  };
  services.nginx = {
    virtualHosts = {
      "code.lillianviolet.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:7773";
        };
      };
    };
  };
}
