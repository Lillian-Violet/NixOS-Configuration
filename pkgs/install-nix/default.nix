{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "install-nix";

  runtimeInputs = [];

  text = ''
    # A rebuild script for NixOS
    sudo systemd-inhibit --who="NixOS Installer" --why="Installing NixOS to /mnt" install-nix-no-inhibit
  '';
}
