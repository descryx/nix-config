{
  osConfig,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.luciole.homeModules.default ];

  config = lib.mkIf osConfig.my.luciole.enable {
    programs.luciole.enable = true;
  };
}
