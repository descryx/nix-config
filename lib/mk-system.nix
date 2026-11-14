# Build one NixOS configuration.
#
# Each host can pick its own nixpkgs and home-manager input, so a stable host
# can coexist with unstable hosts in one flake. `homeUsers` maps Unix user names
# to the home-manager modules that user gets.
{
  inputs,
  overlay,
  system,
}:
{
  hostName,
  nixpkgsInput ? inputs.nixpkgs,
  homeManagerInput ? inputs.home-manager,
  homeUsers,
}:
let
  local = import ../local.nix;
in
nixpkgsInput.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs local;
  };

  modules = [
    ../configuration.nix
    ../hosts/${hostName}/default.nix
    homeManagerInput.nixosModules.home-manager
    inputs.nix-craftapps.nixosModules.default

    {
      nixpkgs.overlays = [
        inputs.mac-style-plymouth.overlays.default
        overlay
      ];

      home-manager = {
        backupFileExtension = "bak";
        useGlobalPkgs = true;
        useUserPackages = true;

        extraSpecialArgs = {
          inherit inputs local;
        };

        # Each value is a list of home-manager modules for that user.
        users = builtins.mapAttrs (_: modules: { imports = modules; }) homeUsers;
      };
    }
  ];
}
