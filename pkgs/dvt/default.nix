{
  lib,
  stdenv,
  direnv,
  writeShellApplication,
}:
stdenv.writeShellApplication
{
  name = "dvt";

  runtimeInputs = [direnv nix];

  text = ''
    nix flake init -t "github:the-nix-way/dev-templates#$1"
    direnv allow
  '';
}
