{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "yamis-icon-theme";
  version = "1.4-unstable-2026-02-06"; # bump the date when you re-pin `rev`

  src = fetchFromGitHub {
    owner = "googIyEYES";
    repo = "YAMIS";
    # Mirror of the canonical set. This is the revision that produced the theme
    # installed at HEAD, so the icons are unchanged from what was there before.
    # The icons live inside monochrome-icon-theme.tar.gz, not as loose files.
    rev = "24c02f6bb7bcd356e49df22f6942b078b66700fd";
    hash = "sha256-KZXG5XYHhUfgDrxOXT1mS+vbmH9l0uEzfdvOo1+r1TQ=";
  };

  dontUnpack = true;

  # Directory name MUST equal `Name` in index.theme ("yet-another-monochrome-icon-set"):
  # GTK and Qt6.11 key off the directory name, Qt <= 6.8 off `Name=`. Matching both is free.
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/share/icons/yet-another-monochrome-icon-set"
    tar -xzf ${finalAttrs.src}/monochrome-icon-theme.tar.gz \
      -C "$out/share/icons/yet-another-monochrome-icon-set" --strip-components=1

    # YAMIS ships only ~5.5k of the ~15k icons an app can request and inherits the
    # rest. Papirus-Dark is not installed, so upstream's Inherits falls through to
    # hicolor anyway; pin it explicitly so that stops being accidental and the set
    # stays purely monochrome. --replace-fail so an upstream edit to this line fails
    # the build loudly instead of silently not applying.
    substituteInPlace "$out/share/icons/yet-another-monochrome-icon-set/index.theme" \
      --replace-fail \
        "Inherits=Papirus-Dark,breeze-dark,Cosmic,Adwaita,hicolor" \
        "Inherits=hicolor"

    runHook postInstall
  '';

  meta = {
    description = "Yet Another Monochrome Icon Set (YAMIS)";
    homepage = "https://github.com/googIyEYES/YAMIS";
    license = lib.licenses.gpl3Only; # LICENSE is verbatim GPLv3, no "or later" grant
    platforms = lib.platforms.linux;
  };
})
