{
  config,
  local,
  pkgs,
  ...
}:
{
  services.easyeffects.enable = true;

  # LV2 plugins the EasyEffects config/presets rely on.
  home.packages = with pkgs; [
    mda_lv2
    calf
    lsp-plugins
    zam-plugins
  ];

  home.file.".config/easyeffects".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/easyeffects/config";
}
