# LearnHarness - prebuilt AppImage, wrapped.
#
# Why a wrapped release binary and not a source build: upstream needs a
# network fetch during `next build` (next/font/google) and an Electron
# binary from a postinstall script, so a from-source derivation is a
# patch-the-build project, not a packaging one. The AppImage is the exact
# artifact the author publishes; `hash` pins its bytes, so this is
# reproducible in the "same input, same output" sense, not in the
# "rebuilt from source" sense.
#
# In-app updates are dead on purpose, and it is not a packaging bug:
# electron-updater needs $APPIMAGE and replaces the file it points at, while a
# Nix store path is read-only. So it logs "APPIMAGE env is not defined" and does
# nothing; if the banner annoys you, turn its 24h check off in
# Settings -> General -> auto update.
#
# Updating: bump `version` and `hash` together -
#   nix store prefetch-file --hash-type sha256 <new AppImage url>
#   (new releases: https://github.com/amosblomqvist/learnharness/releases)
{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "learnharness";
  version = "0.3.7";

  src = fetchurl {
    url = "https://github.com/amosblomqvist/learnharness/releases/download/v${version}/LearnHarness-${version}-x86_64.AppImage";
    hash = "sha256-7zRlGDOxGOpcdEnM2UUFgBB66xg+bHGrFQdrQ7xFGOw=";
  };

  # Extracted a second time by wrapType2 itself; this copy exists only so
  # the icon can be installed under the store's hicolor theme (wrapType2
  # produces a launcher, not desktop assets).
  appimage = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${appimage}/usr/share/icons/hicolor/512x512/apps/learnharness.png \
      $out/share/icons/hicolor/512x512/apps/learnharness.png
  '';

  meta = {
    description = "Agent harness for learning: adaptive teaching, practice, and a persistent knowledge graph";
    homepage = "https://github.com/amosblomqvist/learnharness";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
