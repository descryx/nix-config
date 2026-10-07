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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mac-style-plymouth,
      nix-flatpak,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      gitHooks = import ./git-hooks.nix { inherit inputs nixpkgs system; };
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

            {
              nixpkgs.overlays = [
                inputs.mac-style-plymouth.overlays.default
                (final: _prev: {
                  niri-zoom = final.callPackage ./modules/niri/niri-zoom.nix { };
                  yamis-icon-theme = final.callPackage ./modules/appearance/yamis-icon-theme.nix { };
                  undershell = final.callPackage ./modules/noctalia/undershell.nix { };
                })
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
