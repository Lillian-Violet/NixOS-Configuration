{
  config,
  pkgs,
  ...
}: {
  services.postgresql = {
    # https://nixos.org/manual/nixos/stable/#module-postgresql
    package = pkgs.postgresql_16;
    enable = true;

    # Ensure the database, user, and ownership is set
    ensureDatabases = [
      "nextcloud"
      "onlyoffice"
      "akkoma"
      "gotosocial"
      "gitea"
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
      {
        name = "gitea";
        ensureDBOwnership = true;
      }
    ];
  };
}
