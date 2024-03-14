{
  lib,
  stdenv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "restart";

  runtimeInputs = [killall];

  text = ''
    # Restart script for kde

    killall plasmashell
    kstart plasmashell
  '';
}
