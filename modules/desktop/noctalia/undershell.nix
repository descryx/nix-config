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
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "EternalSelf-2328";
    repo = "undershell";
    rev = "800e27acee6ef9ac881d033959b720998d07c1bb"; # v1.5.1
    hash = "sha256-BAn+YIQLwV8hAgWFfHIDVDvAx6iDCTpGxg1QsXH8fbQ=";
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
  mesonFlags = [
    "-Ddev_paths=false"
    "-Dvideo=disabled" # FFmpeg: video wallpapers on the TV look
    "-Ddepth_model=disabled" # ONNX Runtime: undershell-depth binary
    "-Devolution=disabled" # sqlite: online calendar events
    "-Dscenes=disabled" # liblz4: Wallpaper Engine scenes
    "-Dscripts=disabled" # quickjs-ng: Wallpaper Engine scene scripts
    "-Dgnome_extension=false" # data-only, dead weight under niri
  ];

  meta = {
    description = "Desktop widgets under the shell for Wayland (visualizers, clocks, now-playing)";
    homepage = "https://github.com/EternalSelf-2328/undershell";
    license = lib.licenses.gpl3Plus;
    mainProgram = "undershell";
    platforms = lib.platforms.linux;
  };
}
