{
  config,
  local,
  pkgs,
  ...
}:
let
  link =
    path: config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/terminals/config/${path}";
in
{
  home.packages = with pkgs; [
    ghostty
    kitty
  ];

  home.file = {
    ".config/ghostty".source = link "ghostty";
    ".config/kitty".source = link "kitty";
  };
}
