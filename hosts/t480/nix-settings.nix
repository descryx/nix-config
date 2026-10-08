_: {
  # 4-core laptop: keep build parallelism low so it stays responsive and avoids
  # swapping. Raise if it turns out to have headroom (unverified - tune to taste).
  nix.settings = {
    max-jobs = 2;
    cores = 4;
  };
}
