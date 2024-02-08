{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./aria2
    ./conduit
    ./forgejo
    ./gotosocial
    ./jellyfin
    ./mail-server
    ./nextcloud
    ./ombi
    ./postgres
    ./roundcube
  ];
}
