{
  description = "descryx nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wshowkeys = {
      url = "github:DreamMaoMao/wshowkeys";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    oniri = {
      url = "github:Antiz96/oniri";
      inputs.nixpkgs.follows = "nixpkgs";

    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-craftapps = {
      url = "github:olafkfreund/nix-craftapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mac-style-plymouth,
      nix-flatpak,
      nix-craftapps,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      gitHooks = import ./git-hooks.nix { inherit inputs nixpkgs system; };
      # Custom packages live next to the feature that uses them and reach the
      # hosts through this overlay. Kept as a named value so the same set is
      # also exposed as `packages.<system>` (gives nix-update something to
      # evaluate) without defining any derivation twice.
      overlay = final: _prev: {
        niri-zoom = final.callPackage ./modules/desktop/niri/niri-zoom.nix { };
        yamis-icon-theme = final.callPackage ./modules/desktop/appearance/yamis-icon-theme.nix { };
        localsend-controller = final.callPackage ./modules/desktop/noctalia/localsend-controller.nix { };
        learnharness = final.callPackage ./modules/apps/learnharness/package.nix { };
      };
      pkgsWithOverlay = pkgs.extend overlay;
      mkSystem =
        {
          hostName,
        }:
        let
          local = import ./local.nix;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            inherit local;
          };

          modules = [
            ./configuration.nix
            ./hosts/${hostName}/default.nix
            home-manager.nixosModules.home-manager
            inputs.disko.nixosModules.disko
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
                  inherit inputs;
                  inherit local;
                };
                users.${local.username}.imports = [ ./home.nix ];
              };
            }
          ];
        };
    in
    {
      # The custom packages on their own, so `nix build .#niri-zoom` and
      # `nix-update --flake niri-zoom` work without touching a host config.
      # nix-update finds the file through the derivation's `src`, then rewrites
      # version/rev/hash in place.
      packages.${system} = {
        inherit (pkgsWithOverlay)
          niri-zoom
          yamis-icon-theme
          localsend-controller
          learnharness
          ;
      };
      overlays.default = overlay;
      nixosConfigurations = {
        desk = mkSystem {
          hostName = "desk";
        };
        t480 = mkSystem {
          hostName = "t480";
        };
      };
      checks.${system} = gitHooks.checks;
      devShells.${system} = gitHooks.devShells;
      # Keyed by system (or `default`) or `nix fmt` cannot resolve it. treefmt rather
      # than bare nixfmt because nixfmt gets no file list; config in treefmt.toml.
      # treefmt does not propagate its formatters, so runtimeInputs puts them on PATH.
      # Must be writeShellApplication, not writeShellScript: the latter writes to $out
      # itself rather than $out/bin, which `nix fmt` cannot execute.
      formatter.${system} = pkgs.writeShellApplication {
        name = "treefmt";
        runtimeInputs = [
          pkgs.treefmt
          pkgs.nixfmt
          pkgs.deadnix
        ];
        meta.mainProgram = "treefmt";
        text = ''
          exec treefmt "$@"
        '';
      };
    };

}
