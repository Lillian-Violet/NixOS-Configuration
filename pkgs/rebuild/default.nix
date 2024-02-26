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
    git clone forgejo@git.lillianviolet.dev:Lillian-Violet/NixOS-Config.git ./rebuild
    $hostname=$(hostname)
    pushd ./rebuild
    echo "NixOS Rebuilding..."
    sudo nixos-rebuild switch --flake #$hostname &>nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
    popd
    echo "Cleaning up repository in tmp..."
    rm -rf ./rebuild
    popd
    notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
  '';
}
