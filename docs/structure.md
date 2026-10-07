```
nix-config/
├── flake.nix
├── flake.lock
├── local.nix               # Username, Git email, home/flake dir, etc...
├── configuration.nix       # imports the NixOS (system.nix) side of every feature
├── home.nix                # imports the home-manager (home.nix) side of every feature
├── README.md
├── LICENSE
├── AGENTS.md                           #   Instructions for AI agents / contributors
├── treefmt.toml                        #   nixfmt + deadnix via `nix fmt`
├── git-hooks.nix                       #   pre-commit checks (nixfmt/deadnix/statix/noctalia-scrub/ripsecrets) + devShell
├── .envrc                              #   `use flake` -> direnv loads the devShell
│
├── docs/
│   ├── NOTES.md                        #   SSH + disko tutors, secrets plan, scratch notes
│   ├── COMMANDS.md                     #   Common commands cheat-sheet
│   ├── ARCHITECTURE.md                 #   How the repo is put together and why
│   ├── CREDITS.md                      #   Acknowledgements + third-party notices
│   ├── structure.md                    #   this file
│   └── things-to-remove.md             #   Values to scrub before going public
│
├── scripts/
│   ├── provision.sh                    #   disko-install wrapper for new hosts (untested draft)
│   └── noctalia-scrub.sh               #   strip secret fields from the Noctalia baseline
│
├── hosts/
│   ├── _template/                      #   Scaffold for a new host (copy to hosts/<new>/)
│   │   ├── default.nix
│   │   └── disk-config.nix
│   ├── desk/
│   │   ├── default.nix
│   │   ├── graphics.nix                #   NVIDIA drivers + VA-API
│   │   ├── hardware-configuration.nix
│   │   └── obs.nix                     #   OBS override (CUDA/NVENC)
│   └── t480/
│       ├── default.nix
│       ├── graphics.nix                #   Intel VA-API / compute-runtime
│       ├── batt-tresh.nix
│       └── hardware-configuration.nix
│
├── modules/                            # One folder per app / concern.
│   │                                   #   system.nix  -> NixOS module
│   │                                   #   home.nix    -> home-manager module
│   │                                   #   config/     -> dotfiles symlinked into ~/.config
│   ├── system/                         # Machine foundation (one folder, several files)
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   ├── users.nix
│   │   ├── nix-settings.nix
│   │   ├── nh.nix
│   │   ├── power.nix
│   │   ├── audio.nix
│   │   └── tools.nix                   #   wshowkeys, nix-index, nix-ld, base system pkgs
│   ├── appearance/                     # fonts(system) + gtk/cursor(home) + yamis-icon-theme.nix
│   ├── sddm/                           # system.nix + theme
│   ├── niri/                           # system.nix + home.nix + niri-zoom.nix + config/niri/
│   ├── noctalia/                       # home.nix + undershell.nix + config/{noctalia,undershell}/
│   ├── syncthing/                      # system.nix
│   ├── obs/                            # system.nix (shared); hosts/desk/obs.nix overrides
│   ├── gaming/                         # system.nix (steam, gamemode) + home.nix (gamescope, ...)
│   ├── kdeconnect/                     # system.nix
│   ├── storage/                        # system.nix (udisks2/gvfs/tumbler) + home.nix (udiskie)
│   ├── terminals/                      # home.nix + config/{ghostty,kitty}/
│   ├── nvim/                           # home.nix + config/
│   ├── yazi/                           # home.nix + config/
│   ├── zsh/                            # home.nix
│   ├── opencode/                       # home.nix + skills.nix + config/ + data/
│   ├── vesktop/                        # home.nix + config/
│   ├── zen/                            # home.nix
│   ├── default-apps/                   # home.nix (mime associations)
│   ├── easyeffects/                    # home.nix + config/
│   ├── dev/                            # home.nix (git, direnv, CLI tools) + config/clangd/
│   ├── desktop-apps/                   # home.nix bundle (chrome, gimp, mpv, kdenlive, ...)
│   ├── misc-apps/                      # home.nix bundle (btop, cava, fastfetch, wayscriber)
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
