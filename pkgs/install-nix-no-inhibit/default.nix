{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "install-nix-no-inhibit";

  runtimeInputs = [git gum];

  text = ''
    # An install script for NixOS installation to /tmp
    set -e
    pushd /tmp > /dev/null
    systemd-inhibit --what=idle rm -rf ./install-nix
    systemd-inhibit --what=idle git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git ./install-nix
    pushd ./install-nix/nixos/hosts > /dev/null
    echo "Please choose the hostname you are installing to from the following list:"
    i=1
    for d in */
    do
      dirs[i++]="''${d%/}"
    done
    select dir in "''${dirs[@]}"; do echo "you selected ''${dir}"; break; done
    popd > /dev/null
    pushd ./install-nix > /dev/null
    gum confirm  --default=false \
        "🔥 🔥 🔥 WARNING!!!! This will ERASE ALL DATA on the disk for ''${dir}. Are you sure you want to continue?"

        echo "Partitioning Disks"
        sudo nix run github:nix-community/disko \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        -- \
        --mode zap_create_mount \
        "./disko/''${dir}/default.nix"
    echo "NixOS Installing..."
    systemd-inhibit --what=idle sudo nixos-install --flake .#"''${dir}"
    popd > /dev/null
    echo "Cleaning up repository in '/tmp/install-nix'..."
    systemd-inhibit --what=idle rm -rf ./install-nix
    popd > /dev/null
    echo "NixOS Install Succeeded!"
  '';
}
