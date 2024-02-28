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
    pushd /tmp
    git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./install
    pushd ./install/nixos/hosts
    echo "Please choose the hostname you are installing to from the following list:"
    i=1
    for d in */
    do
      dirs[i++]="$\{d%/}"
    done
    select dir in "$\{dirs[@]}"; do echo "you selected $\{dir}"; break; done
    popd
    pushd ./install
    echo "NixOS Installing..."
    sudo nixos-install --flake .#$dir
    popd
    echo "Cleaning up repository in tmp..."
    rm -rf ./install
    popd
    notify-send -e "NixOS Install Succeeded!" --icon=software-update-available
  '';
}
