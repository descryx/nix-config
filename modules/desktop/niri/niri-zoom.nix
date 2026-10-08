{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wayland,
}:

rustPlatform.buildRustPackage rec {
  pname = "niri-zoom";
  version = "0.1.0-unstable-2026-08-30"; # bump the date when you re-pin `rev`

  src = fetchFromGitHub {
    owner = "Ahmedhossamdev";
    repo = "niri-zoom";
    rev = "8fb682a6a52ff5a53e7187c14807b4e7502749ea"; # pin an actual commit, not "master" — see below
    hash = "sha256-PuLdv0/spVNhUF865+D4uZXOqPquLCb6Ve5Nt2Hh/Co=";
  };

  cargoHash = "sha256-ISKNipvoRpaZ9mx6J9XUialXwuTrpRlNb+0Y5DaNIxY=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ wayland ]; # wayland-client links against libwayland at runtime

  meta = {
    description = "External Ctrl+scroll magnifier/zoom tool for niri (Wayland)";
    homepage = "https://github.com/Ahmedhossamdev/niri-zoom";
    license = lib.licenses.mit;
    mainProgram = "niri-zoomd";
    platforms = lib.platforms.linux;
  };
}
