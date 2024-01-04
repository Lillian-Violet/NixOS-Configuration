{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  users.users.jellyfin.extraGroups = ["nextcloud"];

  services.nginx = {
    virtualHosts = {
      "video.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8096";
        };
      };
    };
  };

  services.jellyfin = {
    enable = true;
  };
}
