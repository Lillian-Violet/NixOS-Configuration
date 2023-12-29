{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];
  users.users = {
    gitea = {
      isSystemUser = true;
      isNormalUser = false;
      extraGroups = ["virtualMail"];
    };
  };
  sops.secrets."mailpassunhash".mode = "0440";
  sops.secrets."mailpassunhash".owner = config.users.users.virtualMail.name;

  services.gitea = {
    enable = true;
    #TODO: different mail passwords for different services
    mailerPasswordFile = config.sops.secrets."mailpassunhash".path;
    database = {
      type = "postgres";
    };
    settings = {
      service.DISABLE_REGISTRATION = true;
      server = {
        DOMAIN = "git.lillianviolet.dev";
        ROOT_URL = "https://git.lillianviolet.dev/";
        HTTP_PORT = 3218;
      };
    };
  };

  services.nginx = {
    virtualHosts = {
      "git.lillianviolet.dev" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:3218";
        };
      };
    };
  };
}
