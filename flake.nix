{
  description = "descryx nixos config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    # The cachix branch always points at a commit CI has cached. Do not add
    # inputs.nixpkgs.follows: overriding an input changes the cache key.
    luciole.url = "github:noctalia-dev/luciole/cachix";
    # Same rule as noctalia/luciole: track the cached branch and leave the
    # input's own nixpkgs alone so its store paths keep matching the cache.
    umbriel.url = "github:noctalia-dev/umbriel/cachix";
    nix-flatpak.url = "github:gmodena/nix-flatpak";

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
        drawy = final.callPackage ./modules/apps/drawy/package.nix { };
      };
      pkgsWithOverlay = pkgs.extend overlay;
      mkSystem = import ./lib/mk-system.nix {
        inherit inputs overlay system;
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
          drawy
          ;
      };
      overlays.default = overlay;
      nixosConfigurations = {
        desk = mkSystem {
          hostName = "desk";
          homeUsers.descryx = [ ./users/descryx/home.nix ];
        };
        t480 = mkSystem {
          hostName = "t480";
          homeUsers.descryx = [ ./users/descryx/home.nix ];
        };
        vivobook = mkSystem {
          hostName = "vivobook";
          nixpkgsInput = inputs.nixpkgs-stable;
          homeManagerInput = inputs.home-manager-stable;
          homeUsers.lena = [
            ./users/lena/home.nix
            inputs.plasma-manager.homeModules.plasma-manager
          ];
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
