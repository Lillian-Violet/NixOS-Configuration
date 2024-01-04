{
  config,
  pkgs,
  ...
}: {
  users.users = {
    aria2.extraGroups = ["jellyfin" "nextcloud"];
  };
  services.aria2 = {
    enable = true;
    downloadDir = "/var/lib/media";
  };

  # services.nginx = {
  #   virtualHosts = {
  #     "aria2.gladtherescake.eu" = {
  #       forceSSL = true;
  #       enableACME = true;
  #       locations."/" = {
  #         proxyPass = "http://localhost:6800";
  #       };
  #     };
  #   };
  # };
}
