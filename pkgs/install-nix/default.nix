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
    # An install script for NixOS installation to /tmp
    set -e
    hostname=$1
    if [[ "$1" == "" ]]; then
      echo "No hostname given, please specify a hostname"
      exit 2
    fi
    pushd /tmp
    git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./install
    pushd ./install
    echo "NixOS Installing..."
    sudo nixos-install --flake .#$1
    popd
    echo "Cleaning up repository in tmp..."
    rm -rf ./install
    popd
    notify-send -e "NixOS Install Succeeded!" --icon=software-update-available
  '';
}
