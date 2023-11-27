{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  users.users.gotosocial.extraGroups = ["virtualMail"];

  services.nginx = {
    virtualHosts = {
      "social.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:4257";
        };
      };
    };
  };

  services.gotosocial = {
    enable = true;
    setupPostgresqlDB = true;
    settings = {
      application-name = "gotosocial";
      host = "social.gladtherescake.eu";
      bind-address = "localhost";
      port = 4257;
      protocol = "https";
      storage-local-base-path = "/var/lib/gotosocial/storage";
      instance-languages = ["en-gb" "nl"];
      media-image-max-size = 41943040;
      media-video-max-size = 209715200;
      media-description-max-chars = 2000;
      smtp-host = "localhost";
      smtp-port = 587;
      smtp-username = "no-reply@social.gladtherescake.eu";
      smtp-password = config.sops.secrets."mailpass".path;
      smtp-from = "no-reply@social.gladtherescake.eu";
    };
  };
}
