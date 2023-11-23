# Nextcloud
{
  config,
  lib,
  pkgs,
  sops,
  ...
}: {
  sops.secrets.nextcloudadmin = {
    mode = "0440";
    owner = config.users.users.nextcloud.name;
    group = config.users.users.nextcloud.group;
  };

  users.users.nextcloud.extraGroups = ["render" "users"];

  environment.systemPackages = with pkgs; [
    unstable.exiftool
    ffmpeg
    nodejs_18
  ];

  # Allow using /dev/dri for Memories
  systemd.services.phpfpm-nextcloud.serviceConfig = {
    PrivateDevices = lib.mkForce false;
  };

  services.nginx.virtualHosts."nextcloud.gladtherescake.eu".listen = [
    {
      addr = "127.0.0.1";
      port = 8180;
    }
  ];

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "nextcloud.gladtherescake.eu";
    database.createLocally = true;
    configureRedis = true;
    appstoreEnable = true;
    config = {
      adminuser = "nextcloud";
      adminpassFile = "${config.sops.secrets.nextcloudadmin.path}";
      dbtype = "mysql";
      defaultPhoneRegion = "US";
      trustedProxies = ["127.0.0.1"];
    };

    extraOptions = {
      mail_smtpmode = "sendmail";
      mail_sendmailmode = "pipe";
      mysql.utf8mb4 = true;
    };

    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
      "upload_max_filesize" = "10G";
      "post_max_size" = "10G";
    };
  };

  services.traefik.dynamicConfigOptions.http.routers.nextcloud = {
    rule = "Host(`nextcloud.gladtherescake.eu`)";
    service = "nextcloud";
    middlewares = ["headers"];
    entrypoints = ["websecure"];
    tls = {
      certResolver = "le";
    };
  };

  services.traefik.dynamicConfigOptions.http.services.nextcloud = {
    loadBalancer = {
      servers = [
        {
          url = "http://localhost:8180";
        }
      ];
    };
  };

  systemd.timers."nextcloud-files-update" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2m";
      OnUnitActiveSec = "15m";
      Unit = "nextcloud-files-update.service";
    };
  };

  systemd.services."nextcloud-files-update" = {
    bindsTo = ["mysql.service" "phpfpm-nextcloud.service"];
    after = ["mysql.service" "phpfpm-nextcloud.service"];
    script = ''

      ${config.services.nextcloud.occ}/bin/nextcloud-occ files:scan -q --all
      ${config.services.nextcloud.occ}/bin/nextcloud-occ preview:pre-generate
    '';

    serviceConfig = {
      User = "nextcloud";
    };

    path = ["config.services.nextcloud" pkgs.perl];
  };
}
