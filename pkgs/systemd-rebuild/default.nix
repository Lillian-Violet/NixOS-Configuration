{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "systemd-rebuild";

  runtimeInputs = [];

  text = ''
    # A rebuild script for NixOS for use of the systemd service
    cd /tmp
    rm -rf ./rebuild
    systemd-inhibit git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./rebuild
    cd ./rebuild
    echo "NixOS Rebuilding..."
    systemd-inhibit nixos-rebuild switch --flake .#
    echo "Cleaning up repository in '/tmp/rebuild'..."
    cd ..
    systemd-inhibit rm -rf ./rebuild
    echo "NixOS Rebuilt OK!"
  '';
}