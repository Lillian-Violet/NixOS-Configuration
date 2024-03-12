{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "rebuild";

  runtimeInputs = [];

  text = ''
    # An upgrade script for nixos
    sudo systemd-inhibit --who="NixOS Updater" --why="Updating flake lock" update
    sudo systemd-inhibit --who="NixOS Updater" --why="Updating system configuration" rebuild-no-inhibit
  '';
}
