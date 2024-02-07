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
    ./dex
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
