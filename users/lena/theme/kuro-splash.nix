{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

# Kuro OLED splash screen. The theme is a KPackage with only splash content;
# it is installed into share/plasma/look-and-feel like a global theme.
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "kuro-splash";
  version = "unstable-2026-01-26";

  src = fetchFromGitHub {
    owner = "bouteillerAlan";
    repo = "kuro";
    rev = "fdef6090b496017f9eb5ac7569937ccb4b60bda9";
    hash = "sha256-9XSAAi/o3xT1i2lEzL7lH3qk052eQvlPlpSfiYDSExA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -d "$out/share/plasma/look-and-feel"
    cp -r a2n.kuro.oled "$out/share/plasma/look-and-feel/"
    runHook postInstall
  '';

  meta = {
    description = "Kuro OLED splash screen for KDE Plasma";
    homepage = "https://github.com/bouteillerAlan/kuro";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
