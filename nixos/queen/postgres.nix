{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    #TODO: update to postgres 15 before migrating to 23.11
    # https://nixos.org/manual/nixos/stable/#module-postgresql
    package = pkgs.postgresql_14;
    enable = true;

    # Ensure the database, user, and ownership is set
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
