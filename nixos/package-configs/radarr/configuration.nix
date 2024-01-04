{
  config,
  pkgs,
  ...
}: {
  users.users = {
    radarr.extraGroups = ["aria2"];
  };
  #uses port 7878
  services.radarr = {
    enable = true;
  };

  services.nginx = {
    virtualHosts = {
      "radarr.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:7878";
        };
      };
    };
  };
}
