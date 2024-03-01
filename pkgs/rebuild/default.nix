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
    pushd /tmp > /dev/null
    rm -rf ./rebuild
    systemd-inhibit --what=idle git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./rebuild
    pushd ./rebuild > /dev/null
    echo "NixOS Rebuilding..."
    systemd-inhibit --what=idle sudo nixos-rebuild switch --flake .#
    popd > /dev/null
    echo "Cleaning up repository in '/tmp/rebuild'..."
    systemd-inhibit --what=idle rm -rf ./rebuild
    popd > /dev/null
    echo "NixOS Rebuilt OK!"
  '';
}
