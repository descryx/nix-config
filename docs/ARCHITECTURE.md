# Architecture

How this repository is put together and why. For the file tree see
[structure.md](structure.md); for day-to-day commands see [COMMANDS.md](COMMANDS.md).

## Design goals

- **Declarative** — packages, services, the compositor, and most app configs are
  described in Nix and rebuilt from a single `flake.lock`.
- **Reproducible** — inputs are pinned; `nix flake check` evaluates both hosts.
- **Live-editable where it matters** — a few large or frequently edited configs
  live as ordinary dotfiles (see below) so changing them doesn't need a rebuild.
- **Multi-host** — shared config in `modules/`, per-machine deltas in `hosts/`.

## Flake structure

`flake.nix` takes inputs (`nixpkgs`, `home-manager`, `disko`, `nix-flatpak`,
`noctalia`, `zen-browser`, `wshowkeys`, `oniri`, `mac-style-plymouth`,
`git-hooks`, …) and exposes:

- `nixosConfigurations.{desk,t480}` — built by a local `mkSystem`, which passes
  `inputs` and `local` through `specialArgs` and enables the home-manager NixOS
  module.
- `checks.${system}.pre-commit-check` and `devShells.${system}.default` — from
  [`git-hooks.nix`](../git-hooks.nix) (nixfmt, deadnix, statix, check-toml,
  detect-private-keys, noctalia-scrub, ripsecrets).
- `formatter.${system}` — the treefmt wrapper used by `nix fmt`.

Custom packages are exposed through an overlay that `callPackage`s the
derivations that live next to the feature that uses them
(`modules/niri/niri-zoom.nix`, `modules/appearance/yamis-icon-theme.nix`,
`modules/noctalia/undershell.nix`).

## NixOS modules & home-manager

- Home-manager is used **as a NixOS module** (`useGlobalPkgs` + `useUserPackages`),
  so system and user configuration build together in one generation.
- `modules/` is organised feature-first: one folder per app or concern, holding
  any of `system.nix` (NixOS module), `home.nix` (home-manager module) and
  `config/` (its dotfiles). The machine foundation that has no natural "app"
  (boot, networking, users, nix settings, `nh`, power, audio, tools) lives
  together in `modules/system/`. `configuration.nix` imports the `system.nix`
  side; `home.nix` imports the `home.nix` side.
- Not-daily-driver pieces (Minecraft, Ollama, OpenRGB, Flatpak, tmux) live under
  `modules/optional/` and are imported by whichever host wants them.
- Per-machine differences live in `hosts/<host>/` (`hardware-configuration.nix`,
  `graphics.nix`, the OBS override, and host-only modules); each `default.nix`
  imports its own.

## The Nix vs dotfiles split

Rule of thumb: **if an app has a good home-manager module, configure it in Nix;
otherwise, or for large/hand-edited files, keep it as a dotfile.** Each feature
keeps its own dotfiles in `modules/<feature>/config/` and its `home.nix` symlinks
them into `~/.config` with `config.lib.file.mkOutOfStoreSymlink`, which points at
the *live repo* rather than a copy in the Nix store, so edits apply immediately.

Examples: `niri`, `noctalia`, `nvim`, `ghostty` are dotfiles; `git`, `zsh`, `mpv`,
GTK, and mime-associations are declarative Nix.

## Hosts

Mounted filesystems are declared in each host's generated
`hardware-configuration.nix`, identified by **filesystem labels**
(`/dev/disk/by-label/nixos`, `/dev/disk/by-label/boot`, …) rather than UUIDs, so
no disk identifiers live in the repo — see [NOTES.md](NOTES.md) → "Filesystem
labels (live hosts)". New machines instead use a disko layout:
`hosts/_template/` ships a `disk-config.nix`, and `scripts/provision.sh` wraps
`disko-install` (see the disko tutor in [NOTES.md](NOTES.md)). Adopting disko for
the live hosts is deferred.

## Secrets

Three identifiers are kept out of the tracked config by design:

- **Noctalia plugin keys** — the tracked baseline
  (`modules/noctalia/config/noctalia/noctalia-config.toml`) is regenerated with
  `scripts/noctalia-export.sh`, which scrubs it and refuses to write a file that
  still carries sensitive fields. The keys themselves live per-machine in
  `~/.local/state/noctalia/settings.toml` (see
  [COMMANDS.md](COMMANDS.md) → "Noctalia config & secrets").
- **Syncthing device IDs** — paired at runtime in
  `~/.config/syncthing/config.xml`, not declared in Nix.
- **Disk identifiers** — filesystems are mounted by label, not UUID.

`local.nix` holds only non-secret values (username, paths, noreply git email). A
manager (agenix/sops) is deferred until there is a system-level secret; the
options are in [NOTES.md](NOTES.md) → "Secrets & keys (future plan)".

## Build & deploy

Rebuilds go through [`nh`](https://github.com/viperML/nh): `nh os switch`
(activate + boot default), `nh os boot`, `nh os test`, `nh os rollback`,
`nh clean all`. `nixos-rebuild` is not used.

One rule matters: **never update `flake.lock` on the laptop.** Updates happen on
`desk`, then are pushed and pulled.

For changes to *filesystem mounts* (e.g. moving a host to `by-label`), apply with
`nh os boot` and reboot — `nh os switch` cannot remount `/` or `/home` live and
reports `failed to restart home.mount`.
