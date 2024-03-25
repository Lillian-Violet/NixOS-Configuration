# This file defines overlays
{inputs, ...}: {
  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    steam = prev.steam.override {
      extraProfile = ''export LD_PRELOAD=${inputs.extest}/lib/libextest.so:$LD_PRELOAD'';
    };
  };

  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    import ../pkgs {
      inherit (final) callPackage;
      pkgs = final;
    };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  pkg-sets = (
    final: prev: {
      stable = import inputs.nixos-stable {system = final.system;};
    }
  );
}
