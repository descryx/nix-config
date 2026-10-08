{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland-protocols,
  wayland,
  libGL,
  pipewire,
  tomlplusplus,
  glib,
  cairo,
  pango,
  fontconfig,
  libxkbcommon,
  systemd,
  gdk-pixbuf,
  curl,
  nlohmann_json,
}:

stdenv.mkDerivation rec {
  pname = "undershell";
  version = "1.2.1-unstable-2026-10-05";

  src = fetchFromGitHub {
    owner = "EternalSelf-2328";
    repo = "undershell";
    rev = "7ecdfe5cd4ce12cdf47ba47962630dcbdd93a123";
    hash = "sha256-kycWI2yYolLxMU4KQoJQFrLd2UovFRL/B3O1bTxDJ50=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    wayland-protocols
  ];

  buildInputs = [
    wayland
    libGL
    pipewire
    tomlplusplus
    glib
    cairo
    pango
    fontconfig
    libxkbcommon
    systemd
    gdk-pixbuf
    curl
    nlohmann_json
  ];

  # Do not bake the build tree path into the binary: with dev_paths the
  # bundled fonts resolve out of the source dir instead of $out/share/undershell.
  mesonFlags = [ "-Ddev_paths=false" ];

  meta = {
    description = "Desktop widgets under the shell for Wayland (visualizers, clocks, now-playing)";
    homepage = "https://github.com/EternalSelf-2328/undershell";
    license = lib.licenses.gpl3Plus;
    mainProgram = "undershell";
    platforms = lib.platforms.linux;
  };
}
