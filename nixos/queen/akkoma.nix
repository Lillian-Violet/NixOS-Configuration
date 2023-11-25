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
    config = {
      ":pleroma".":instance" = {
        name = "GLaDTheresCake Akkoma";
        email = "akkoma@gladtherescake.eu";
        notify_email = "no-reply@akkoma.gladtherescake.eu";
        languages = ["en" "nl"];
        registrations_open = false;
        max_pinned_statuses = 10;
        cleanup_attachments = true;
      };
    };
  };
}
