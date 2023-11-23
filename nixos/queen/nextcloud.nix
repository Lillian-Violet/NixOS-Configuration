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
      dbhost = "mysql";
      dbname = "NC";
      #dbpassFile = config.sops.secrets."nextclouddb".path;

      adminpassFile = config.sops.secrets."nextcloudadmin".path;
      adminuser = "gladtherescake";
    };
  };

  services.mysql = {
    settings = {
      server = {
        skip_name_resolve = 1;
        innodb_buffer_pool_size = "128M";
        innodb_buffer_pool_instances = 1;
        innodb_flush_log_at_trx_commit = 2;
        innodb_log_buffer_size = "32M";
        innodb_max_dirty_pages_pct = 90;
        query_cache_type = 1;
        query_cache_limit = "2M";
        query_cache_min_res_unit = "2k";
        query_cache_size = "64M";
        tmp_table_size = "64M";
        max_heap_table_size = "64M";
        slow_query_log = 1;
        long_query_time = 1;
      };
      mysqld = {
        port = 3306;
        character_set_server = "utf8mb4";
        collation_server = "utf8mb4_general_ci";
        transaction_isolation = "READ-COMMITTED";
        binlog_format = "ROW";
        innodb_large_prefix = "on";
        innodb_file_format = "barracuda";
        innodb_file_per_table = 1;
      };
    };

    enable = true;

    package = pkgs.mariadb_110;

    #Directory for the database is /var/lib/mysql

    # Ensure the database, user, and permissions always exist
    ensureDatabases = ["NC"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions = {
          "NC.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };

  systemd.services."sops-nix.service" = {
    before = ["nextcloud-setup.service" "mysql.service"];
  };

  systemd.services."nextcloud-setup" = {
    requires = ["mysql.service"];
    after = ["mysql.service"];
  };
}
