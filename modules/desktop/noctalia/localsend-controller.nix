{
  lib,
  rustPlatform,
  fetchgit,
}:

rustPlatform.buildRustPackage {
  pname = "localsend-controller";
  version = "2.5.0";

  # The helper ships inside the localsend-plus plugin, which Noctalia clones at
  # runtime and auto-updates. Building it here needs a pinned source instead, so
  # fetch only the plugin dir from the community repo: sparseCheckout keeps the
  # fetch at ~750 KiB, and rev + both hashes are the pin.
  src = fetchgit {
    url = "https://github.com/noctalia-dev/community-plugins";
    rev = "3411d6a2ec4a84852d4a40e20089d1e9aa315940";
    sparseCheckout = [ "localsend-plus" ];
    hash = "sha256-E11b4OFpxY1MiqYOY+q5IHvJlz4A3oB4HQj499IQlDQ=";
  };

  # The crate is a workspace member, not the repo root.
  cargoRoot = "localsend-plus/controller";
  buildAndTestSubdir = "localsend-plus/controller";

  # Covers the crates.io deps per Cargo.lock and the LocalSend core git dep at
  # rev 44f48f18 (v1.19.0). The tests start two daemons on loopback and pass in
  # the sandbox.
  cargoHash = "sha256-okxl42B2JcBX1LRAcqRKdD5NYucs3ls4ap8rRqVKSNM=";

  meta = {
    description = "LocalSend receiver/sender daemon for the Noctalia localsend-plus plugin";
    homepage = "https://github.com/noctalia-dev/community-plugins";
    license = lib.licenses.mit;
    mainProgram = "localsend-controller";
    platforms = lib.platforms.linux;
  };
}
