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
    echo "use flake \"github:the-nix-way/dev-templates?dir=$1\"" >> .envrc
    direnv allow
  '';
}
