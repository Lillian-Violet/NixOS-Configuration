{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    enable = true;

    # Ensure the database, user, and permissions always exist
    ensureDatabases = [
      "nextcloud"
      "onlyoffice"
      "akkoma"
      "gotosocial"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "onlyoffice";
        ensureDBOwnership = true;
      }
      {
        name = "akkoma";
        ensureDBOwnership = true;
      }
      {
        name = "gotosocial";
        ensureDBOwnership = true;
      }
    ];
  };
}
