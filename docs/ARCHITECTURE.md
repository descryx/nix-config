# Architecture

How the repo fits together. File tree in [structure.md](structure.md), day-to-day
commands in [COMMANDS.md](COMMANDS.md).

## Design

- Declarative: packages, services, the compositor and quite some app configs
  are Nix, rebuilt from one `flake.lock`.
- Reproducible: inputs are pinned, and `nix flake check` evaluates both hosts.
- Live-editable where it matters: a few large or frequently edited configs stay
  as plain dotfiles.
- Multi-host: shared config in `modules/`, per-machine deltas in `hosts/`.

## Flake structure

`flake.nix` takes the inputs (`nixpkgs`, `home-manager`, `disko`, `nix-flatpak`,
`noctalia`, `zen-browser`, `wshowkeys`, `oniri`, `mac-style-plymouth`,
`git-hooks`) and exposes:

- `nixosConfigurations.{desk,t480}`, built by a local `mkSystem` that passes
  `inputs` and `local` through `specialArgs` and enables the home-manager NixOS
  module.
- `checks.${system}.pre-commit-check` and `devShells.${system}.default`, from
  [`git-hooks.nix`](../git-hooks.nix).
- `formatter.${system}`, the treefmt wrapper used by `nix fmt`.

Custom packages come from an overlay that `callPackage`s the derivations kept next
to the feature that uses them (`modules/niri/niri-zoom.nix`,
`modules/appearance/yamis-icon-theme.nix`, `modules/noctalia/undershell.nix`).

## Modules and home-manager

Home-manager runs as a NixOS module (`useGlobalPkgs` + `useUserPackages`), so
system and user config build together in one generation.

`modules/` is feature-first: one folder per app or concern, holding any of
`system.nix` (NixOS module), `home.nix` (home-manager module) and `config/` (its
dotfiles). The machine foundation that has no natural app (boot, networking,
users, Nix settings, `nh`, power, audio, tools) lives in `modules/system/`.
`configuration.nix` imports the `system.nix` side and `home.nix` imports the
`home.nix` side. Optional pieces live in `modules/optional/` and are imported by
whichever host wants them. Per-machine differences live in `hosts/<host>/`.

## Nix vs dotfiles

"Rule": if an app has a good home-manager module, configure it in Nix; otherwise,
or for large and hand-edited files, keep it as a dotfile. Each feature keeps its
dotfiles in `modules/<name>/config/`, and `home.nix` links them into `~/.config`
with `mkOutOfStoreSymlink`, which points at the live repo instead of a copy in the
Nix store, so edits apply immediately. Examples: `niri`, `noctalia`, `nvim` and
`ghostty` are dotfiles; `git`, `zsh`, `mpv`, GTK and the mime associations are
Nix.

## Hosts, secrets, deploy

The detail lives in [NOTES.md](NOTES.md) (filesystem labels, disko) and
[COMMANDS.md](COMMANDS.md) (mounts, rebuilds). What matters here:

- Filesystems are mounted by label, not UUID, so no disk IDs are in the repo.
- Noctalia plugin keys, Syncthing device IDs and disk identifiers are kept out of
  the tracked config. See [Noctalia config & secrets](COMMANDS.md#noctalia-config--secrets).
- Rebuilds go through `nh`; never update `flake.lock` on the laptop.
- For filesystem/mount changes, use `nh os boot` and reboot, not `nh os switch`.
