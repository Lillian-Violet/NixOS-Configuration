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
    set -e
    echo "NixOS Rebuilding..."
    sudo systemd-inhibit --who="System Updater" --why="Updating System" nixos-rebuild switch --flake git+https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git#
    echo "NixOS Rebuilt OK!"
  '';
}
