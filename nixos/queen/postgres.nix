{
  config,
  pkgs,
  ...
}: {
  #Define postgres here so this is the only place to update its version
  postgresPackage = postgresql_15.withPackages (pp: [
    # pp.plv8
  ]);
  services.postgresql = {
    # https://nixos.org/manual/nixos/stable/#module-postgresql
    package = pkgs.${postgresPackage};
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
