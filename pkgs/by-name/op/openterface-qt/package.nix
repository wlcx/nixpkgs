{
  lib,
  stdenv,
  makeDesktopItem,
  copyDesktopItems,
  fetchFromGitHub,
  qt6,
  libusb1,
}:
let
  version = "0.0.5";
  description = "Openterface mini-KVM host application for linux";
in
stdenv.mkDerivation {
  pname = "openterface-qt";
  inherit version;
  src = fetchFromGitHub {
    owner = "TechxArtisanStudio";
    repo = "Openterface_QT";
    rev = "v${version}";
    hash = "sha256-pe7idedtlxGGlNUvXQjIF57m2wW+WlWVM0BYOR+CxBU=";
  };
  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    libusb1
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtserialport
    qt6.qtsvg
  ];
  buildPhase = ''
    runHook preBuild
    mkdir build
    cd build
    qmake6 ..
    make -j$NIX_BUILD_CORES
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./openterfaceQT $out/bin/
    mkdir -p $out/share/pixmaps
    cp ../images/icon_256.png $out/share/pixmaps/icon.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "openterfaceQT";
      exec = "openterfaceQT";
      icon = "icon";
      comment = description;
      desktopName = "Openterface QT";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    inherit description;
    homepage = "https://github.com/TechxArtisanStudio/Openterface_QT";
    license = lib.licenses.agpl3Only;
    mainProgram = "openterfaceQT";
    maintainers = with lib.maintainers; [ samw ];
    platforms = lib.platforms.linux;
  };
}
