{
  config,
  pkgs,
  ...
}: {
  sops.secrets."nextcloudadmin".mode = "0440";
  sops.secrets."nextcloudadmin".owner = config.users.users.nextcloud.name;
  sops.secrets."nextclouddb".mode = "0440";
  sops.secrets."nextclouddb".owner = config.users.users.nextcloud.name;
  sops.secrets."local.json".mode = "0440";
  sops.secrets."local.json".owner = config.users.users.onlyoffice.name;

  users.users = {
    nextcloud.extraGroups = [config.users.groups.keys.name "aria2" "onlyoffice"];
    aria2.extraGroups = ["nextcloud"];
    onlyoffice.extraGroups = ["nextcloud"];
  };

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

    package = pkgs.nextcloud28;

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
    # Further forces Nextcloud to use HTTPS
    settings = {
      overwriteprotocol = "https";
      default_phone_region = "NL";
      maintenance_window_start = 3;
    };
    appstoreEnable = true;
    extraAppsEnable = true;
    #extraApps = with config.services.nextcloud.package.packages.apps; {
    # List of apps we want to install and are already packaged in
    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
    # inherit calendar contacts deck forms notes onlyoffice polls twofactor_nextcloud_notification unsplash;
    #};

    config = {
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
