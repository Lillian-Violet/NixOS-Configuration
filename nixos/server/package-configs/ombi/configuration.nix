{
  config,
  pkgs,
  ...
}: {
  users.users = {
    ombi.extraGroups = ["radarr" "sonarr" "aria2" "nextcloud"];
  };
  services.ombi = {
    enable = true;
    port = 2368;
  };

  users.users = {
    radarr.extraGroups = ["aria2" "nextcloud"];
    sonarr.extraGroups = ["aria2" "nextcloud"];
  };

  services = {
    #uses port 7878
    radarr.enable = true;
    #uses port 8989
    sonarr.enable = true;
    prowlarr.enable = true;
  };

  services.nginx = {
    virtualHosts = {
      "ombi.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:2368";
        };
      };
      "radarr.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:7878";
        };
      };
      "sonarr.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8989";
        };
      };
      "prowlarr.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:9696";
        };
      };
    };
  };
}
