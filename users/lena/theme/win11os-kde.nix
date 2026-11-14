{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "win11os-kde";
  version = "unstable-2025-06-26";

  src = fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "Win11OS-kde";
    rev = "9f021c3e71da7baf59a0614ab858d53b1e455fd5";
    hash = "sha256-R1l0YG+UEfFKPJd/pQJ3aJzWKg1ru0gWasW7zStK1Ig=";
  };

  nativeBuildInputs = [ jq ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/look-and-feel \
             $out/share/plasma/desktoptheme \
             $out/share/aurorae/themes \
             $out/share/color-schemes

    cp -r plasma/look-and-feel/* $out/share/plasma/look-and-feel/
    cp -r plasma/desktoptheme/* $out/share/plasma/desktoptheme/
    cp -r aurorae/* $out/share/aurorae/themes/
    cp color-schemes/*.colors $out/share/color-schemes/

    theme=$out/share/plasma/look-and-feel/com.github.yeyushengfan258.Win11OS-dark

    # All components are installed here, so the KDE Store dependency prompts
    # would only ask for things we already ship.
    jq 'del(."X-KPackage-Dependencies")' "$theme/metadata.json" > "$theme/metadata.json.tmp"
    mv "$theme/metadata.json.tmp" "$theme/metadata.json"
    sed -i '/^X-KPackage-Dependencies=/d' "$theme/metadata.desktop"

    # Upstream defaults ask for Kvantum and the Win10 cursor theme, which are
    # not packaged, and for the non-black icon set. Use the packaged pieces.
    substituteInPlace "$theme/contents/defaults" \
      --replace-fail 'Theme=Win11' 'Theme=Win11-black-dark' \
      --replace-fail 'widgetStyle=kvantum' 'widgetStyle=Breeze' \
      --replace-fail 'cursorTheme=Win10OS-cursors' 'cursorTheme=breeze_cursors'

    runHook postInstall
  '';

  meta = {
    description = "Win11OS-dark KDE Plasma theme";
    homepage = "https://github.com/yeyushengfan258/Win11OS-kde";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
