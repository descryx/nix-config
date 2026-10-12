{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.opt.flatpak;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.opt.flatpak.enable = lib.mkEnableOption "flatpak";

  config = lib.mkIf cfg.enable {
    services = {
      flatpak.enable = true;
      flatpak.packages = [ "org.vinegarhq.Sober" ];
    };
  };
}
