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
    systemd-inhibit rm -rf /tmp/rebuild
    systemd-inhibit git clone https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config.git /tmp/rebuild
    systemd-inhibit echo "NixOS Rebuilding..."
    systemd-inhibit nixos-rebuild switch --flake /tmp/rebuild/#
    systemd-inhibit echo "Cleaning up repository in '/tmp/rebuild'..."
    systemd-inhibit rm -rf /tmp/rebuild
    systemd-inhibit echo "NixOS Rebuilt OK!"
  '';
}
