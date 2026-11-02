{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage {
  pname = "localsend-controller";
  version = "2.4.0";

  # The helper ships inside the localsend-plus plugin, which Noctalia clones at
  # runtime and auto-updates. Building it here needs a pinned source instead, so
  # fetch only the plugin dir from the community repo: sparseCheckout keeps the
  # fetch at ~750 KiB, and rev + both hashes are the pin.
  src = fetchgit {
    url = "https://github.com/noctalia-dev/community-plugins";
    rev = "fc41baf743f45fc40e6ad9737a30f13c10cdf081";
    sparseCheckout = [ "localsend-plus" ];
    hash = "sha256-QwZdfQqQ5JhESz2blfpigGQcAxZ+ot06s0cUDS6psyo=";
  };

  # The crate is a workspace member, not the repo root.
  cargoRoot = "localsend-plus/controller";
  buildAndTestSubdir = "localsend-plus/controller";

  # Covers the crates.io deps per Cargo.lock and the LocalSend core git dep at
  # rev 82abda3. The tests start two daemons on loopback and pass in the sandbox.
  cargoHash = "sha256-BQ6u9cBoQ+MVv7Zf+a/l7Ga337O4tRvGmzeZSnEik+8=";

  meta = {
    description = "LocalSend receiver/sender daemon for the Noctalia localsend-plus plugin";
    homepage = "https://github.com/noctalia-dev/community-plugins";
    license = lib.licenses.mit;
    mainProgram = "localsend-controller";
    platforms = lib.platforms.linux;
  };
}
