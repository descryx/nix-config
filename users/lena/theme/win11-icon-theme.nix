{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  coreutils,
  findutils,
  gnused,
  gtk3,
}:
stdenvNoCC.mkDerivation (_finalAttrs: {
  pname = "win11-icon-theme";
  version = "unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "Win11-icon-theme";
    rev = "a5b460a407da143b32f19a503d7fcebb3edf2371";
    hash = "sha256-+GtOkOVSWlNTdKSs0R86LhnpbBZ21Y0ML3V8pwDUUSc=";
  };

  nativeBuildInputs = [
    bash
    coreutils
    findutils
    gnused
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons

    # Upstream's parser is out of sync with THEME_VARIANTS: the `purple` label
    # maps to THEME_VARIANTS[1], which is "-black". Rename that label so
    # `-t black` installs Win11-black and Win11-black-dark as intended.
    sed -i 's/^\( *\)purple)/\1black)/' install.sh

    bash install.sh -d $out/share/icons -n Win11 -t black

    # Upstream ships a few hundred dangling color-variant symlinks. Nix rejects
    # broken links in the store, and KDE falls back for those icons anyway.
    find $out -xtype l -delete

    runHook postInstall
  '';

  meta = {
    description = "Win11 icon theme";
    homepage = "https://github.com/yeyushengfan258/Win11-icon-theme";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
