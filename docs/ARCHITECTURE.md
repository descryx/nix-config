# Architecture

How the repo fits together. Day-to-day commands are in
[COMMANDS.md](COMMANDS.md); the layout is `modules/<category>/<feature>/`.

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
`nix-craftapps`, `git-hooks`) and exposes:

- `nixosConfigurations.{desk,t480}`, built by a local `mkSystem` that passes
  `inputs` and `local` through `specialArgs` and enables the home-manager NixOS
  module.
- `checks.${system}.pre-commit-check` and `devShells.${system}.default`, from
  [`git-hooks.nix`](../git-hooks.nix).
- `packages.${system}` and `overlays.default`: the custom packages as standalone
  build targets (`nix build .#niri-zoom`) and the same set as an overlay, so
  each derivation is defined once and nix-update has something to evaluate.
- `formatter.${system}`, the treefmt wrapper used by `nix fmt`.

Plain `nix flake check` evaluates the module graph but never instantiates the
toplevel, so errors that only appear at derivation time (a missing path literal
from a moved file, a bad derivation) slip through. `scripts/check-systems.sh`
forces instantiation of each host's system in its own short-lived `nix eval`
process; it stays a script rather than a flake check so the heaviest command
stays light.

Custom packages come from an overlay defined once in `flake.nix` that
`callPackage`s the derivations kept next to the feature that uses them
(`modules/desktop/niri/niri-zoom.nix`,
`modules/desktop/appearance/yamis-icon-theme.nix`,
`modules/desktop/noctalia/localsend-controller.nix`,
`modules/apps/learnharness/package.nix`). Each pins its upstream source by
revision or release hash. `localsend-controller` is the one that has to track an
updater it does not control, because Noctalia updates the plugin it belongs to at
runtime; see [COMMANDS.md](COMMANDS.md#noctalia-plugin-dependencies).

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
- `optional/` - off by default; imported always but a host opts in with
  `opt.<feature>.enable`.

`system/` is the exception to the folder rule: it holds one file per concern
(`boot.nix`, `networking.nix`, ...) and has no per-feature `system.nix`/`home.nix`
split.

A feature never splits across categories: its `system.nix`, `home.nix` and
`config/` stay in one folder. Per-machine differences live in `hosts/<host>/`.

## Toggles

Every feature has an `enable` option, off by default. Modules are imported
permanently - `configuration.nix` imports every `system.nix`, `home.nix` every
`home.nix` - and a feature is turned on or off only through its option, never by
removing an import. This is the whole point of the option approach: the shared
import lists never change, so a host cannot silently drop a feature by editing
them.

- Core features use `my.<feature>.enable`; optional features use
  `opt.<feature>.enable` (declared in `modules/optional/*/system.nix`).
- `configuration.nix` lists every option once, as a by-hand lookup table. Shared
  features use `lib.mkDefault true`, the rest `lib.mkDefault false`. `lib.mkDefault`
  is essential: it makes the value only a *default*, so a host can still override
  it; a plain `= true` there would conflict with a host's `= false`.
- `hosts/<host>/default.nix` carries only the deltas, as plain `= true`/`= false`
  (normal priority beats `lib.mkDefault`). Features wanted on both machines stay in
  `configuration.nix`; only real per-machine differences live in the host file.
- A feature with both halves is gated by one switch: `system.nix` uses
  `lib.mkIf cfg.enable`; `home.nix` reads the same system option through `osConfig`
  (`lib.mkIf osConfig.my.<feature>.enable`). Home-manager runs as a NixOS module, so
  `osConfig` exposes the merged system option tree.

Because the option default is off, a feature mentioned nowhere is off.
`configuration.nix` is the one place to look an option up.

| Group | Switch | Enabled in |
|---|---|---|
| core (niri, noctalia, zsh, nvim, gaming, ...) | `my.<feature>.enable` | `configuration.nix` (on), overridden per host |
| kdeconnect | `my.kdeconnect.enable` | `hosts/desk/default.nix` |
| optional (flatpak, minecraft, ollama, openrgb, tmux) | `opt.<feature>.enable` | `hosts/<host>/default.nix` |

Watch the soft couplings: `default-apps` points at `zen.desktop`, `nvim.desktop`,
`thunar.desktop`, `mpv.desktop`, `imv.desktop`, `libreoffice-*` and
`org.qbittorrent.qBittorrent.desktop`, so disabling those leaves dangling mime
defaults (harmless, but tidy them up). The desk-only OBS override
(`hosts/desk/obs.nix`) is gated by `my.obs.enable`, so it is inert when OBS is off.

One deliberate coupling is inverted: `modules/apps/dev/python` owns the single
`python3` interpreter and exposes `local.python.extensions`, a list any feature
contributes to (Noctalia's shelf plugin was the only user and has been removed, so
the list is empty today). This exists because two `python3` derivations in the
same profile collide, so only one module may build the interpreter. The option is
declared unconditionally and only the interpreter package is gated by
`my.dev.enable`, so a contributor staying enabled while `dev` is off is harmless
(it just contributes an unused package).

## Nix vs dotfiles

"Rule": if an app has a good home-manager module, configure it in Nix; otherwise,
or for large and hand-edited files, keep it as a dotfile. Each feature keeps its
dotfiles in `modules/<category>/<feature>/config/`, and `home.nix` links them into
`~/.config` with `mkOutOfStoreSymlink`, which points at the live repo instead of a
copy in the Nix store, so edits apply immediately. Examples: `niri`, `noctalia`,
`nvim`, `yazi` and `ghostty` are dotfiles; `git`, `zsh`, `mpv`, GTK, the mime
associations, `btop`/`cava` (`programs.btop`/`programs.cava`) and the clangd user
config are Nix.

Generated files stay live even when their feature is Nix: Noctalia writes the
`btop`/`cava`/`yazi` themes into the real `~/.config/<app>/themes/` (or
`flavors/`) at runtime, so palette changes apply without a rebuild.

One file is the deliberate exception. opencode rewrites its TUI settings by
writing `cli.json.tmp` and renaming it over `~/.config/opencode/cli.json`, which
replaces any symlink home-manager put there. So that entry sets `force = true`:
the file opencode wrote is moved to `cli.json.bak` and the declared version is
relinked, which means a TUI toggle lasts only until the next switch. Edit
`modules/apps/opencode/home.nix` to change those settings for good.

## Hosts & deploy

- Filesystems are mounted by label, not UUID (the labels are in
  [NOTES.md](NOTES.md)), so no disk IDs are in the repo.
- Rebuilds go through `nh`; see [COMMANDS.md](COMMANDS.md). Never update
  `flake.lock` on the laptop. For filesystem/mount changes, use `nh os boot` and
  reboot, not `nh os switch`.

## Secrets

Rule: never put a secret value in the repo. What is kept out, and why:

- Noctalia plugin API keys are entered per machine in the Settings UI and stored
  in `~/.local/state/noctalia/settings.toml`, never the repo: `rylos/syncthing`,
  `zumik3-del/opencode-go-usage`, `Wallhaven`. Regenerate the tracked (secret-free)
  baseline with `scripts/noctalia-export.sh`, see
  [COMMANDS.md](COMMANDS.md#noctalia-config--secrets).
- Syncthing pairs at runtime (`~/.config/syncthing/config.xml`), so no device IDs
  live here; filesystems are mounted by label, so no disk UUIDs live here.
- The git identity uses the GitHub noreply address (`local.nix`).
- Hooks guard it: `noctalia-scrub` strips credential fields and refuses a write
  that still has one, `detect-private-keys` catches PEM keys, and `ripsecrets` is
  the catch-all scanner.
