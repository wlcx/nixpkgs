{
  lib,
  stdenv,
  makeDesktopItem,
  copyDesktopItems,
  fetchFromGitHub,
  writeText,
  qt6,
  libusb1,
  udev,
  pkg-config,
  ffmpeg,
  libx11,
  libxrandr,
  libxrender,
  libva,
}:
let
  # Based on upstream instructions: https://github.com/TechxArtisanStudio/Openterface_QT#for-linux-users
  udevRules = writeText "60-openterface.rules" ''
    # ID 1a86:7523 QinHeng Electronics CH340 serial converter
    SUBSYSTEM=="ttyUSB", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", TAG+="uaccess"

    # ID 534d:2109 MacroSilicon Openterface
    SUBSYSTEM=="usb", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="534d", ATTRS{idProduct}=="2109", TAG+="uaccess"
  '';
in
stdenv.mkDerivation (finalAttrs: {
  pname = "openterface-qt";
  version = "0.5.25";
  src = fetchFromGitHub {
    owner = "TechxArtisanStudio";
    repo = "Openterface_QT";
    rev = "${finalAttrs.version}";
    hash = "sha256-NvbPrYmTigQ6SQg3MO/zmH4b0fVMfcMynsHrBeifwG8=";
  };
  nativeBuildInputs = [
    copyDesktopItems
    qt6.wrapQtAppsHook
    qt6.qmake
    qt6.qttools
    pkg-config
  ];
  buildInputs = [
    libusb1
    udev
    ffmpeg
    libva
    libx11
    libxrandr
    libxrender
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtserialport
    qt6.qtsvg
  ];
  preBuild = ''
    lrelease openterfaceQT.pro
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ./openterfaceQT $out/bin/
    mkdir -p $out/share/pixmaps
    cp ./images/icon_256.png $out/share/pixmaps/openterface-qt.png
    mkdir -p $out/etc/udev/rules.d
    cp ${udevRules} $out/etc/udev/rules.d/60-openterface.rules
    runHook postInstall
  '';

  doInstallCheck = true;

  desktopItems = [
    (makeDesktopItem {
      name = "openterfaceQT";
      exec = "openterfaceQT";
      icon = finalAttrs.pname;
      comment = finalAttrs.meta.description;
      desktopName = "Openterface QT";
      categories = [ "Utility" ];
    })
  ];

  meta = {
    description = "Openterface mini-KVM host application for linux";
    homepage = "https://github.com/TechxArtisanStudio/Openterface_QT";
    license = lib.licenses.agpl3Only;
    mainProgram = "openterfaceQT";
    maintainers = with lib.maintainers; [ samw ];
    platforms = lib.platforms.linux;
  };
})
