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
    nix flake init -t "github:the-nix-way/dev-templates#$1"
    direnv allow
  '';
}
