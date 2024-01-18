{
  lib,
  stdenv,
  direnv,
  writeShellApplication,
}:
writeShellApplication
{
  name = "dvt";

  runtimeInputs = [direnv];

  text = ''
    nix flake init -t "git+https://git.lillianviolet.dev/Lillian-Violet/dev-templates#$1"
    direnv allow
  '';
}
