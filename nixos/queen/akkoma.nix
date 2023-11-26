{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  users.groups.akkoma = {};

  users.users = {
    akkoma = {
      isSystemUser = true;
      group = "akkoma";
    };
  };

  services.akkoma = {
    enable = true;
    package = pkgs.akkoma;
    extraPackages = with pkgs; [ffmpeg exiftool imagemagick];
    nginx = {
      enableACME = true;
      forceSSL = true;
      serverName = "akkoma.gladtherescake.eu";
    };
    dist.cookie._secret = config.sops.secrets."releaseCookie".path;

    config = {
      ":pleroma".":instance" = {
        name = "GLaDTheresCake Akkoma";
        email = "akkoma@gladtherescake.eu";
        notify_email = "no-reply@akkoma.gladtherescake.eu";
        emails.mailer = {
          enabled = true;
          adapter = "Swoosh.Adapters.Sendmail";
          cmd_path = "/run/wrappers/bin/sendmail";
          cmd_args = "-N delay,failure,success";
          qmail = true;
        };
        frontends = {
          primary = {
            package = pkgs.akkoma-frontends.akkoma-fe;
            name = "akkoma-fe";
            ref = "stable";
          };
          admin = {
            package = pkgs.akkoma-frontends.admin-fe;
            name = "admin-fe";
            ref = "stable";
          };
        };
        description = "Lillian's Akkoma server!";
        languages = ["en" "nl"];
        registrations_open = true;
        max_pinned_statuses = 10;
        cleanup_attachments = true;
      };
    };
  };
}
