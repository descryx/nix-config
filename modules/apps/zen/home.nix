{
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.zen.enable {
    home.packages = [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
