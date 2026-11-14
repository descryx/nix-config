{
  local,
  lib,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = local.flakeDir;
    clean = {
      enable = true;
      extraArgs = lib.mkDefault "--keep 10";
      dates = "daily";
    };
  };
}
