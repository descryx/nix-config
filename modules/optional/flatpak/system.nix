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

  config = lib.mkIf cfg.enable {
    services = {
      flatpak.enable = true;
      flatpak.packages = [ "org.vinegarhq.Sober" ];
    };
  };
}
