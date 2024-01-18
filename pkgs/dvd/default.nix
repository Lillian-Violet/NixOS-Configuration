{
  lib,
  stdenv,
  direnv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "dvd";

  runtimeInputs = [direnv];

  text = ''
    echo "use flake \"git+https://git.lillianviolet.dev/Lillian-Violet/dev-templates.git?dir=$1\" --no-write-lock-file" >> .envrc
    direnv allow
  '';
}
