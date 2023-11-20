{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  #this came from https://jacobneplokh.com/how-to-setup-nextcloud-on-nixos/
  services.nginx = {
    enable = true;

    # Use recommended settings
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Only allow PFS-enabled ciphers with AES256
    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    # Setup Nextcloud virtual host to listen on ports
    virtualHosts = {
      "nextcloud.gladtherescake.eu" = {
        ## Force HTTP redirect to HTTPS
        forceSSL = true;
        ## LetsEncrypt
        enableACME = true;
      };
    };
  };

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.gladtherescake.eu";

    # Use HTTPS for links
    https = true;

    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "05:00:00";

    configureRedis = true;

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets "nextclouddb".path;

      #TODO: work with sops to set this instead of a file & make sure the db setup is the same as on the previous server for easy migration
      adminpassFile = config.sops.secrets."nextcloudadmin".path;
      adminuser = "admin";
    };
  };

  services.postgresql = {
    enable = true;

    # Ensure the database, user, and permissions always exist
    ensureDatabases = ["nextcloud"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
