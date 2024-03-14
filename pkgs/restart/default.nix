{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "restart";

  runtimeInputs = [];

  text = ''
    # Restart script for kde

    killall plasmashell
    kstart plasmashell
  '';
}
