{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage {
  pname = "localsend-controller";
  version = "2.3.2";

  # The helper ships inside the localsend-plus plugin, which Noctalia clones at
  # runtime and auto-updates. Building it here needs a pinned source instead, so
  # fetch only the plugin dir from the community repo: sparseCheckout keeps the
  # fetch at ~750 KiB, and rev + both hashes are the pin.
  src = fetchgit {
    url = "https://github.com/noctalia-dev/community-plugins";
    rev = "03072098ee3374dddfc4d7b0e6469437f818b783";
    sparseCheckout = [ "localsend-plus" ];
    hash = "sha256-m9c3kM/S9xGbvzrDtxAg/Wn3cq+nd0kTEFUhluTpkpk=";
  };

  # The crate is a workspace member, not the repo root.
  cargoRoot = "localsend-plus/controller";
  buildAndTestSubdir = "localsend-plus/controller";

  # Covers the crates.io deps per Cargo.lock and the LocalSend core git dep at
  # rev 82abda3. The tests start two daemons on loopback and pass in the sandbox.
  cargoHash = "sha256-7sJAY7q/FycP95EVnFzcZ6MevCXYD4S1B3fi4qI9YOA=";

  meta = {
    description = "LocalSend receiver/sender daemon for the Noctalia localsend-plus plugin";
    homepage = "https://github.com/noctalia-dev/community-plugins";
    license = lib.licenses.mit;
    mainProgram = "localsend-controller";
    platforms = lib.platforms.linux;
  };
}
