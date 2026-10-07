{
  local,
  ...
}:
{
  # Syncthing is paired at runtime: its device IDs and folder config live in
  # ~/.config/syncthing/config.xml, not in this repo. Pair each machine once in
  # the UI (or by copying that file). Starts at boot.
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = local.username;
    dataDir = "${local.homeDir}/.local/state/syncthing";
    configDir = "${local.homeDir}/.config/syncthing";
    # Index DB and logs; otherwise defaults to configDir. Keeps the (large) DB
    # out of ~/.config.
    databaseDir = "${local.homeDir}/.local/state/syncthing";
  };
}
