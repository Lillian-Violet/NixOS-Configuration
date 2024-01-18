{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [];
  #users.groups.gitea = {};
  #users.users = {
  #  gitea = {
  #    openssh.authorizedKeys.keys = [
  #      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYgErCnva8fvLvsmTMC6dHJp2Fvwja0BYL8K/58ugDxNA0PVGj5PpEMar5yhi4AFGGYL4EgD75tRgI/WQU87ZiKjJ6HFIhgX9curncB2kIJ0JoA+FIQMNOT72GFuhjcO4svanrobsMrRmcn193suXY/N6m6F+3pitxBfHPWuPKKjlZqVBzpqCdz9pXoGOk48OSYv7Zyw8roVsUw3fqJqs68LRLM/winWVhVSPabXGyX7PAAW51Nbv6M64REs+V1a+wGvK5sGhRy7lIBAIuD22tuL4/PZojST1hasKN+7cSp7F1QTi4u0yeQ2+gIclQNuhfvghzl6zcVEpOycFouSIJaJjo8jyuHkbm4I2XfALVTFHe7sLpYNNS7Mf6E6i5rHvAvtXI4UBx/LjgPOj7RWZFaotxQRk1D+N0y2xNrO4ft6mS+hrJ/+ybp1XTGdtlkpUDKjiTZkV7Z4fq9J0jtijvtxRfcPhjia50IIHtZ28wVBMCCwYzh5pR15F/XbvKCc= lillian@EDI"
  #      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
  #    ];
  #    isSystemUser = true;
  #    isNormalUser = false;
  #    group = "gitea";
  #    extraGroups = ["virtualMail"];
  #  };
  #};
  
  sops.secrets."mailpassunhash".mode = "0440";
  sops.secrets."mailpassunhash".owner = config.users.users.virtualMail.name;

  services.forgejo = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/var/lib/gitea";
    #TODO: different mail passwords for different services
    mailerPasswordFile = config.sops.secrets."mailpassunhash".path;
    database = {
      user = "gitea";
      name = "gitea";
      type = "postgres";
    };
    settings = {
      "cron.sync_external_users" = {
        RUN_AT_START = true;
        SCHEDULE = "@every 24h";
        UPDATE_EXISTING = true;
      };
      mailer = {
        ENABLED = true;
        PROTOCOL = "sendmail";
        FROM = "no-reply@git.lillianviolet.dev";
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
        SENDMAIL_ARGS = "-bs";
      };
      repository = {
        ENABLE_PUSH_CREATE_USER = true;
      };
      federation = {
        ENABLED = true;
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
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
