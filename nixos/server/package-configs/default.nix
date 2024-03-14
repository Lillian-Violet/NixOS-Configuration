{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # ./conduit
    ./forgejo
    ./gotosocial
    ./mail-server
    ./nextcloud
    ./postgres
    ./roundcube
  ];
}
