{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
}:

# Fluent Round Dark global theme, with the look-and-feel defaults patched to
# the components actually used: Win11 color scheme and icons, Breeze Plasma
# style, Bibata cursors and the Kuro OLED splash.
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "fluent-kde-round-dark";
  version = "unstable-2026-11-28";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Fluent-kde";
    rev = "44794f29c89de994b0179aebabd2f5776c90d236";
    hash = "sha256-Ejr2wDs3tr36YN2mWSd9ZKp5e6gH/whcuhauN/2Y15I=";
  };

  nativeBuildInputs = [ jq ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/share/aurorae/themes" \
               "$out/share/plasma/look-and-feel"
    cp -r aurorae/Fluent-round-dark "$out/share/aurorae/themes/"
    cp -r plasma/look-and-feel/com.github.vinceliuice.Fluent-round-dark \
      "$out/share/plasma/look-and-feel/"

    theme="$out/share/plasma/look-and-feel/com.github.vinceliuice.Fluent-round-dark"

    # The package ships its own splash; the live setup uses Kuro instead.
    rm -rf "$theme/contents/splash"

    substituteInPlace "$theme/contents/defaults" \
      --replace-fail 'cursorTheme=Fluent-dark-cursors' 'cursorTheme=Bibata-Original-Classic' \
      --replace-fail 'ColorScheme=FluentDark' 'ColorScheme=Win11OSDark' \
      --replace-fail 'Theme=Fluent-dark' 'Theme=Win11-black-dark' \
      --replace-fail 'widgetStyle=kvantum-dark' 'widgetStyle=Breeze' \
      --replace-fail 'name=Fluent-round-dark' 'name=default'

    cat >> "$theme/contents/defaults" <<'EOF'

    [ksplashrc][KSplash]
    Engine=KSplashQML
    Theme=a2n.kuro.oled
    EOF

    # The KDE Store dependencies are shipped or replaced by the patch above.
    jq 'del(."X-KPackage-Dependencies")' "$theme/metadata.json" > "$theme/metadata.json.tmp"
    mv "$theme/metadata.json.tmp" "$theme/metadata.json"

    runHook postInstall
  '';

  meta = {
    description = "Fluent Round Dark global theme with local component overrides";
    homepage = "https://github.com/vinceliuice/Fluent-kde";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
