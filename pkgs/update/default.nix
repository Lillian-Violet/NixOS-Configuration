{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "update";

  runtimeInputs = [];

  text = ''
    # A script to update the flake lock for NixOS
    set -e
    pushd /tmp > /dev/null
    rm -rf ./update
    git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./update
    pushd ./update > /dev/null
    echo "Updating flake lock..."
    nix flake update
    git add flake.lock
    git commit -m "update flake lock"
    git push
    popd > /dev/null
    echo "Cleaning up repository in '/tmp/update'..."
    rm -rf ./update
    popd > /dev/null
    echo "Flake lock update OK!"
  '';
}
