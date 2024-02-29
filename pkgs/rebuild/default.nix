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
    pushd /tmp
    rm -rf ./rebuild
    git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./rebuild
    pushd ./rebuild
    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch --flake .#
    popd
    echo "Cleaning up repository in tmp..."
    rm -rf ./rebuild
    popd
    notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
  '';
}
