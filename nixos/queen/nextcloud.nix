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

    package = pkgs.nextcloud27;

    #Directory for the data is /var/lib/nextcloud

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "mysql";
      dbuser = "nextcloud";
      dbhost = "/run/mysql";
      dbname = "NC";
      dbpassFile = config.sops.secrets."nextclouddb".path;

      #TODO: work with sops to set this instead of a file & make sure the db setup is the same as on the previous server for easy migration
      adminpassFile = config.sops.secrets."nextcloudadmin".path;
      adminuser = "admin";
    };
  };

  services.mysql = {
    enable = true;

    package = pkgs.mariadb_110;

    #Directory for the database is /var/lib/mysql
    settings = {
      mysqld = {
        innodb_force_recovery = 10;
      };
      mariadb = {
        log_error = /var/log/mysql/mysql_error.log;
      };
    };

    # Ensure the database, user, and permissions always exist
    ensureDatabases = ["NC"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE NC" = "ALL PRIVILEGES";
      }
    ];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["mysql.service"];
    after = ["mysql.service"];
  };
}
