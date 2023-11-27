{
  config,
  pkgs,
  ...
}: {
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
      {
        name = "gotosocial";
        ensurePermissions."DATABASE gotosocial" = "ALL PRIVILEGES";
      }
    ];
  };
}
