```
nix-config/
├── flake.nix
├── flake.lock
├── local.nix               # Username, git email, paths
├── configuration.nix       # imports the NixOS (system.nix) side of every feature
├── home.nix                # imports the home-manager (home.nix) side of every feature
├── README.md
├── LICENSE
├── AGENTS.md                           #   Instructions for AI agents / contributors
├── treefmt.toml                        #   nixfmt + deadnix via `nix fmt`
├── git-hooks.nix                       #   pre-commit checks + devShell (see docs/COMMANDS.md)
├── .envrc                              #   `use flake` -> direnv loads the devShell
│
├── docs/
│   ├── NOTES.md                        #   Tutors (SSH, disko) + working notes
│   ├── COMMANDS.md                     #   Commands cheat-sheet
│   ├── ARCHITECTURE.md                 #   How the repo fits together (+ Toggles map)
│   ├── CREDITS.md                      #   Acknowledgements + third-party notices
│   ├── structure.md                    #   this file
│   └── things-to-remove.md             #   Values to scrub before going public
│
├── scripts/
│   ├── provision.sh                    #   disko-install wrapper for new hosts (untested draft)
│   ├── noctalia-export.sh              #   safe Noctalia export -> scrub -> check -> write
│   └── noctalia-scrub.sh               #   strip credential fields from the Noctalia baseline
│
├── hosts/
│   ├── _template/                      #   Scaffold for a new host (copy to hosts/<new>/)
│   │   ├── default.nix
│   │   └── disk-config.nix
│   ├── desk/
│   │   ├── default.nix
│   │   ├── graphics.nix                #   NVIDIA drivers
│   │   ├── hardware-configuration.nix
│   │   └── obs.nix                     #   OBS override (CUDA/NVENC)
│   └── t480/
│       ├── default.nix
│       ├── graphics.nix                #   Intel VA-API / compute-runtime
│       ├── batt-tresh.nix
│       └── hardware-configuration.nix
│
├── modules/                            # One folder per feature, grouped by category.
│   │                                   #   A feature holds any of:
│   │                                   #     system.nix -> NixOS module
│   │                                   #     home.nix   -> home-manager module
│   │                                   #     config/    -> dotfiles symlinked into ~/.config
│   ├── system/                         # Machine foundation (one folder, several files)
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── users.nix
│   │   ├── nix-settings.nix
│   │   ├── nh.nix
│   │   ├── power.nix
│   │   ├── audio.nix
│   │   └── tools.nix                   #   wshowkeys, nix-index, nix-ld, base system pkgs
│   ├── desktop/                        # The session and how it looks
│   │   ├── niri/                       # system.nix + home.nix + niri-zoom.nix + config/niri/
│   │   ├── noctalia/                   # home.nix + undershell.nix + config/{noctalia,undershell}/
│   │   ├── appearance/                 # fonts (system) + gtk/cursor (home) + yamis-icon-theme.nix
│   │   └── sddm/                       # system.nix (SDDM + theme)
│   ├── apps/                           # One app / concern per folder
│   │   ├── nvim/                       # home.nix + config/
│   │   ├── yazi/                       # home.nix + config/
│   │   ├── terminals/                  # home.nix + config/{ghostty,kitty}/
│   │   ├── zen/                        # home.nix
│   │   ├── vesktop/                    # home.nix + config/
│   │   ├── opencode/                   # home.nix + skills.nix + config/ + data/
│   │   ├── dev/                        # home.nix (git, direnv, CLI tools) + config/clangd/
│   │   ├── zsh/                        # home.nix
│   │   ├── easyeffects/                # home.nix + config/
│   │   ├── obs/                        # system.nix (shared); hosts/desk/obs.nix overrides
│   │   ├── gaming/                     # system.nix (steam, gamemode) + home.nix (gamescope)
│   │   ├── btop/                       # home.nix + config/
│   │   ├── cava/                       # home.nix + config/
│   │   ├── fastfetch/                  # home.nix + config/
│   │   └── wayscriber/                 # home.nix + config/
│   ├── services/                       # Background daemons and device glue
│   │   ├── syncthing/                  # system.nix
│   │   ├── kdeconnect/                 # system.nix
│   │   └── storage/                    # system.nix (udisks2/gvfs/tumbler) + home.nix (udiskie)
│   ├── bundles/                        # Grouped package lists / default choices (no per-app folders)
│   │   ├── default-apps/               # home.nix (mime associations)
│   │   └── desktop-apps/               # home.nix bundle (browsers, media, creative apps)
│   └── optional/                       # Not daily-driver; imported per host
│       ├── minecraft/                  # system.nix
│       ├── ollama/                     # system.nix + assets/ (Modelfiles)
│       ├── openrgb/                    # system.nix
│       ├── flatpak/                    # system.nix (+ Sober)
│       └── tmux/                       # home.nix
│
├── screenshots/
└── wallpapers/                         # sddm background (bg.png)
```
