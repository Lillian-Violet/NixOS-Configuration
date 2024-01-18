{
  lib,
  stdenv,
  direnv,
  writeShellApplication,
}:
stdenv.writeShellApplication
{
  name = "dvd";

  runtimeInputs = [echo direnv];

  text = ''
    echo "use flake \"github:the-nix-way/dev-templates?dir=$1\"" >> .envrc
    direnv allow
  '';
}
