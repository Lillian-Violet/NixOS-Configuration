{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  zlib,
  glib,
  harfbuzz,
  fontconfig,
  freetype,
  dbus,
  libunwind,
  gst_all_1,
  xorg,
  libxkbcommon,
  vulkan-loader,
}:
stdenv.mkDerivation rec {
  pname = "servo";
  version = "2024-01-05";

  src = fetchurl {
    url = "https://github.com/servo/servo-nightly-builds/releases/download/${version}/servo-latest.tar.gz";
    hash = "sha256-IlmoYIFk0QO0CieJ49m8PnEou1Q3w+Tk9rypI0ya2WQ=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs =
    [
      stdenv.cc.cc.lib
      zlib
      glib
      harfbuzz
      fontconfig
      freetype
      dbus
      libunwind
    ]
    ++ (with gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-bad
    ])
    ++ (with xorg; [
      libxcb
      libX11
    ]);

  runtimeDependencies =
    [
      libxkbcommon
      vulkan-loader
    ]
    ++ (with xorg; [
      libXcursor
      libXrandr
      libXi
    ]);

  sourceRoot = "servo";

  installPhase = ''
    runHook preInstall
    install -m755 -D servo $out/bin/._servo
    echo "WINIT_UNIX_BACKEND=x11 $out/bin/._servo" > $out/bin/servo
    chmod +x $out/bin/servo
    cp -r ./resources $out/bin/
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://servo.org";
    description = "The embeddable, independent, memory-safe, modular, parallel web rendering engine";
    platforms = platforms.linux;
  };
}
