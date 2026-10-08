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
to the feature that uses them (`modules/desktop/niri/niri-zoom.nix`,
`modules/desktop/appearance/yamis-icon-theme.nix`,
`modules/desktop/noctalia/undershell.nix`).

## Modules and home-manager

Home-manager runs as a NixOS module (`useGlobalPkgs` + `useUserPackages`), so
system and user config build together in one generation.

`modules/` is feature-first and grouped by domain: each feature lives in its own
`modules/<category>/<feature>/` folder, holding any of `system.nix` (NixOS
module), `home.nix` (home-manager module) and `config/` (its dotfiles).
`configuration.nix` imports the `system.nix` side and `home.nix` imports the
`home.nix` side. Categories:

- `system/` - machine foundation that has no natural app (boot, networking,
  users, Nix settings, `nh`, power, audio, tools).
- `desktop/` - the session and how it looks: `niri`, `noctalia`, `appearance`,
  `sddm`.
- `apps/` - one app or concern per folder.
- `services/` - background daemons and device glue: `syncthing`, `kdeconnect`,
  `storage`.
- `bundles/` - grouped package lists and default choices, with no per-app folders:
  `default-apps`, `desktop-apps`.
- `optional/` - not installed by default; imported by whichever host wants them.

A feature never splits across categories: its `system.nix`, `home.nix` and
`config/` stay in one folder. Per-machine differences live in `hosts/<host>/`.

## Toggles

Features are enabled by importing their file(s), so disabling one is commenting
out its import line. Some features have both a `system.nix` and a `home.nix`
half, which means one line in each of `configuration.nix` and `home.nix`; the
import lists carry a comment pointing at the other half. `optional/` features are
imported (or not) per host in `hosts/<host>/default.nix`.

| Feature | File(s) to edit |
|---|---|
| syncthing, kdeconnect, sddm | `configuration.nix` |
| obs | `configuration.nix` + `hosts/desk/obs.nix` (desk override) |
| niri, gaming, appearance, storage | `configuration.nix` + `home.nix` |
| noctalia, nvim, yazi, terminals, vesktop, zen, opencode, easyeffects, dev, zsh, btop, cava, fastfetch, wayscriber | `home.nix` |
| default-apps, desktop-apps | `home.nix` |
| optional/* (flatpak, minecraft, ollama, openrgb, tmux) | `hosts/<host>/default.nix` |

Watch the soft couplings: `default-apps` points at `zen.desktop`, `nvim.desktop`,
`thunar.desktop`, `mpv.desktop`, `imv.desktop`, `libreoffice-*` and
`org.qbittorrent.qBittorrent.desktop`, so disabling those leaves dangling mime
defaults (harmless, but tidy them up). The desk-only OBS override
(`hosts/desk/obs.nix`) is meaningless once `modules/apps/obs/system.nix` is not
imported.

## Nix vs dotfiles

"Rule": if an app has a good home-manager module, configure it in Nix; otherwise,
or for large and hand-edited files, keep it as a dotfile. Each feature keeps its
dotfiles in `modules/<category>/<feature>/config/`, and `home.nix` links them into
`~/.config` with `mkOutOfStoreSymlink`, which points at the live repo instead of a
copy in the Nix store, so edits apply immediately. Examples: `niri`, `noctalia`,
`nvim`, `yazi` and `ghostty` are dotfiles; `git`, `zsh`, `mpv`, GTK and the mime
associations are Nix.

## Hosts, secrets, deploy

The detail lives in [NOTES.md](NOTES.md) (filesystem labels, disko) and
[COMMANDS.md](COMMANDS.md) (mounts, rebuilds). What matters here:

- Filesystems are mounted by label, not UUID, so no disk IDs are in the repo.
- Noctalia plugin keys, Syncthing device IDs and disk identifiers are kept out of
  the tracked config. See [Noctalia config & secrets](COMMANDS.md#noctalia-config--secrets).
- Rebuilds go through `nh`; never update `flake.lock` on the laptop.
- For filesystem/mount changes, use `nh os boot` and reboot, not `nh os switch`.
