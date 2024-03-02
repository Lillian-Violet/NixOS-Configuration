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
    # A rebuild script for NixOS
    sudo systemd-inhibit --who="NixOS Updater" --why="Updating system configuration" rebuild-no-inhibit"
  '';
}
