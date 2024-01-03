{
  config,
  pkgs,
  ...
}: {
  #uses port 8989
  services.radarr = {
    enable = true;
  };

  services.nginx = {
    virtualHosts = {
      "sonarr.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8989";
        };
      };
    };
  };
}
