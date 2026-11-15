{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

# Pure QML Plasma wallpaper plugin (no build step); requires Plasma >= 6.3.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "plasma-wallpaper-active-blur";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "bouteillerAlan";
    repo = "blurredwallpaper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Iit74EAHnB8LBF8/Pcg5RZ/Bb4QZkiWvVGkg9Z+GOo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -d "$out/share/plasma/wallpapers"
    cp -r a2n.blur "$out/share/plasma/wallpapers/"
    runHook postInstall
  '';

  meta = {
    description = "Plasma wallpaper plugin that blurs and darkens the wallpaper while a window is active";
    homepage = "https://github.com/bouteillerAlan/blurredwallpaper";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
