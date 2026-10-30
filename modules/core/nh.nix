{
  local,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = local.flakeDir;
    clean = {
      enable = true;
      extraArgs = "--keep 10";
      dates = "daily";
    };
  };
}
