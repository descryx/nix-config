{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
  services = {
    flatpak.enable = true;
    flatpak.packages = [ "org.vinegarhq.Sober" ];
  };
}
