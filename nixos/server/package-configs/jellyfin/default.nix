{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  users.users.jellyfin.extraGroups = ["nextcloud" "aria2"];

  services.nginx = {
    virtualHosts = {
      "video.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:8096";
          proxyWebsockets = true; # needed if you need to use WebSocket
        };
      };
    };
  };

  services.jellyfin = {
    enable = true;
  };
}
