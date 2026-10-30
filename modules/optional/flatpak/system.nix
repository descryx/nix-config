{
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.flatpak;
in
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  options.my.flatpak.enable = lib.mkEnableOption "flatpak";

  config = lib.mkIf cfg.enable {
    services = {
      flatpak.enable = true;
      flatpak.packages = [ "org.vinegarhq.Sober" ];
    };
  };
}
