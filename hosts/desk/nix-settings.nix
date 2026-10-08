_: {
  # 12 cores but only 15 GiB RAM. `max-jobs = auto` ran 12 builds at once, each
  # allowed all 12 cores, which pushed nix-daemon past 11 GiB and thrashed the
  # box. Bound both dimensions: 4 concurrent derivations, 4 cores each. Raise if
  # builds feel slow and memory pressure stays low; lower if it thrashes again.
  nix.settings = {
    max-jobs = 4;
    cores = 4;
  };
}
