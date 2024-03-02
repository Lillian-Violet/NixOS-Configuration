# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  dvd = pkgs.callPackage ./dvd {};
  dvt = pkgs.callPackage ./dvt {};
  servo = pkgs.callPackage ./servo {};
  rebuild-no-inhibit = pkgs.callPackage ./rebuild-no-inhibit {};
  rebuild = pkgs.callPackage ./rebuild {};
  install-nix = pkgs.callPackage ./install-nix {};
}
