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

  services.nginx = {
    virtualHosts = {
      "ombi.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:2368";
        };
      };
    };
  };
}
