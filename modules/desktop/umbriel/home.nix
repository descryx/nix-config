{
  config,
  local,
  osConfig,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.umbriel.enable {
    # Umbriel live-reloads config.toml and its includes. An out-of-store symlink
    # keeps edits in the repo live, the same pattern as modules/desktop/niri.
    home.file.".config/umbriel".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/desktop/umbriel/config/umbriel";
  };
}
