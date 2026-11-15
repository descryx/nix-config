{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  gettext,
  pkg-config,
  qt6,
  kdePackages,
  shared-mime-info,
  zstd,
}:

# Not in nixpkgs. Needs Qt >= 6.9 and KF6 >= 6.19; 26.05 has 6.11 / 6.26.
stdenv.mkDerivation (finalAttrs: {
  pname = "drawy";
  version = "1.0.2";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "graphics";
    repo = "drawy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lFI4q5/RKA49rcI2iSJuwYfShgOjM+EAfXM+5ZSG8SA=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    gettext
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    kdePackages.kcrash
    kdePackages.kcoreaddons
    kdePackages.kwidgetsaddons
    kdePackages.kconfig
    kdePackages.kconfigwidgets
    kdePackages.kxmlgui
    kdePackages.kiconthemes
    kdePackages.ki18n
    kdePackages.syntax-highlighting
    shared-mime-info
    zstd
  ];

  cmakeFlags = [ (lib.cmakeBool "BUILD_TESTING" false) ];

  meta = {
    description = "Infinite whiteboard for ideas, diagrams and visual notes";
    homepage = "https://apps.kde.org/drawy/";
    license = lib.licenses.gpl3Plus;
    mainProgram = "drawy";
    platforms = lib.platforms.linux;
  };
})
