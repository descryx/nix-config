{
  config,
  local,
  pkgs,
  ...
}:
let
  link =
    path: config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/misc-apps/config/${path}";
in
{
  home.packages = with pkgs; [
    btop
    cava
    fastfetch
    wayscriber
  ];

  home.file = {
    ".config/btop".source = link "btop";
    ".config/cava".source = link "cava";
    ".config/fastfetch".source = link "fastfetch";
    ".config/wayscriber".source = link "wayscriber";
  };
}
