{
  config,
  pkgs,
  ...
}: {
  # Enable Nginx
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
      "onlyoffice.gladtherescake.eu" = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };

  # Actual Nextcloud Config
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.gladtherescake.eu";

    package = pkgs.nextcloud27;

    # Use HTTPS for links
    https = true;

    # Auto-update Nextcloud Apps
    autoUpdateApps.enable = true;
    # Set what time makes sense for you
    autoUpdateApps.startAt = "05:00:00";
    configureRedis = true;
    maxUploadSize = "16G";

    #Increase opcache string buffer
    phpOptions."opcache.interned_strings_buffer" = "23";

    extraAppsEnable = true;
    extraApps = with config.services.nextcloud.package.packages.apps; {
      # List of apps we want to install and are already packaged in
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      inherit calendar contacts deck forms music news notes onlyoffice polls twofactor_nextcloud_notification unsplash;
    };

    config = {
      # Further forces Nextcloud to use HTTPS
      overwriteProtocol = "https";

      defaultPhoneRegion = "NL";

      # Nextcloud PostegreSQL database configuration, recommended over using SQLite
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
      dbname = "nextcloud";
      dbpassFile = config.sops.secrets."nextclouddb".path;

      adminpassFile = config.sops.secrets."nextcloudadmin".path;
      adminuser = "GLaDTheresCake";
    };
  };

  services.onlyoffice = {
    enable = true;
    hostname = "onlyoffice.gladtherescake.eu";
    #postgresHost = "/run/postgesql";
    #postgresUser = "onlyoffice";
    #postgresName = "onlyoffice";
    #jwtSecretFile = config.sops.secrets."local.json".path;
  };

  services.rabbitmq = {
    enable = true;
  };

  # Enable PostgreSQL
  services.postgresql = {
    enable = true;

    # Ensure the database, user, and permissions always exist
    ensureDatabases = ["nextcloud" "onlyoffice" "akkoma"];
    ensureUsers = [
      {
        name = "nextcloud";
        ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
      }
      {
        name = "onlyoffice";
        ensurePermissions."DATABASE onlyoffice" = "ALL PRIVILEGES";
      }
      {
        name = "akkoma";
        ensurePermissions."DATABASE akkoma" = "ALL PRIVILEGES";
      }
    ];
  };

  services.aria2 = {
    enable = true;
    rpcListenPort = 6969;
  };

  systemd.services."sops-nix.service" = {
    before = [
      "nextcloud-setup.service"
      "postgresql.service"
      "onlyoffice-converter.service"
      "onlyoffice-docservice.service"
      "nginx.service"
      "phpfpm-nextcloud.service"
      "redis-nextcloud.service"
    ];
  };

  # Ensure that postgres is running before running the setup
  systemd.services."nextcloud-setup" = {
    requires = ["postgresql.service"];
    after = ["postgresql.service"];
  };
}
