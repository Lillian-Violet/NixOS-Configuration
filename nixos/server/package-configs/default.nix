{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./conduit
    ./forgejo
    ./gotosocial
    ./jellyfin
    ./mail-server
    ./nextcloud
    ./postgres
    ./roundcube
  ];
}
