{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "rebuild-no-inhibit";

  runtimeInputs = [];

  text = ''
    # A rebuild script for NixOS

    set -e
    pushd /tmp > /dev/null
    rm -rf ./rebuild
    git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./rebuild
    pushd ./rebuild > /dev/null
    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch --flake .#
    popd > /dev/null
    echo "Cleaning up repository in '/tmp/rebuild'..."
    rm -rf ./rebuild
    popd > /dev/null
    echo "NixOS Rebuilt OK!"
  '';
}
