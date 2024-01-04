{
  config,
  pkgs,
  ...
}: {
  users.users = {
    sonarr.extraGroups = ["aria2"];
  };
  #uses port 8989
  services.sonarr = {
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
