# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  dvd = pkgs.callPackage ./dvd {};
  dvt = pkgs.callPackage ./dvt {};
}