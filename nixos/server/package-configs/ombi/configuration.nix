{
  config,
  pkgs,
  ...
}: {
  users.users = {
    ombi.extraGroups = ["radarr" "sonarr" "aria2"];
  };
  services.ombi = {
    enable = true;
    port = 2368;
  };

  users.users = {
    radarr.extraGroups = ["aria2"];
    sonarr.extraGroups = ["aria2"];
    prowlarr = {
      group = "prowlarr";
      extraGroups = ["aria2"];
    };
  };
  #uses port 7878
  services.radarr = {
    enable = true;
  };

  #uses port 8989
  services.sonarr = {
    enable = true;
  };

  services.prowlarr = {
    enable = true;
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
