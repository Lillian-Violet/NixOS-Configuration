{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "upgrade";

  runtimeInputs = [];

  text = ''
    # An upgrade script for nixos
    update
    sudo systemd-inhibit --who="NixOS Updater" --why="Updating system configuration" rebuild-no-inhibit
  '';
}
