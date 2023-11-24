{
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
      addSSL = true;
      enableACME = true;
      forceSSL = true;
      serverName = "akkoma.gladtherescake.eu";
    };
  };
}
