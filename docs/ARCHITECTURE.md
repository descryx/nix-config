# Architecture

How the repo fits together. Day-to-day commands are in
[COMMANDS.md](COMMANDS.md); the layout is `modules/<category>/<feature>/`.

## Design

- Declarative: packages, services, the compositor and quite some app configs
  are Nix, rebuilt from one `flake.lock`.
- Reproducible: inputs are pinned, and `nix flake check` evaluates all hosts.
- Live-editable where it matters: a few large or frequently edited configs stay
  as plain dotfiles.
- Multi-host: shared config in `modules/`, per-machine deltas in `hosts/`.
- Multi-user: home-manager roots live in `users/<name>/home.nix`; a host
  declares which users it gets in `flake.nix`. A user can live-symlink the
  owner's dotfiles or get store copies (`my.dotfiles.live`), so a second user
  never depends on the owner's home directory.

## Flake structure

`flake.nix` takes the inputs (`nixpkgs`, `nixpkgs-stable`, `home-manager`,
`home-manager-stable`, `nix-flatpak`, `noctalia`, `zen-browser`,
`zen-browser-pinned`, `plasma-manager`, `wshowkeys`, `oniri`,
`mac-style-plymouth`, `nix-craftapps`, `git-hooks`) and exposes:

- `nixosConfigurations.{desk,t480,vivobook}`, built by
  [`lib/mk-system.nix`](../lib/mk-system.nix), which takes the nixpkgs and
  home-manager inputs and a per-host `homeUsers` map. Desk and t480 use unstable;
  Vivobook uses `nixpkgs-stable` (26.05) and `home-manager-stable`. The builder
  passes `inputs` and `local` through `specialArgs` and enables the home-manager
  NixOS module.
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

Home-manager roots are per-user, not per-host: `users/descryx/home.nix` imports
the auto-discovered module set, while `users/lena/home.nix` imports a curated
subset (zsh, ghostty, nvim, zen, learnharness) plus KDE. The flake's
`homeUsers` map decides which users a host gets, which keeps a second user's
packages and config out of the owner's profile.

`modules/` is feature-first and grouped by domain: each feature lives in its own
`modules/<category>/<feature>/` folder, holding any of `system.nix` (NixOS
module), `home.nix` (home-manager module) and `config/` (its dotfiles).

Both halves are imported by file name, not from a list: [`lib/modules.nix`](../lib/modules.nix)
walks `modules/` and picks up `system.nix`, `home.nix` and everything in
`modules/core/`. Adding a feature means adding a folder - there is no import
line to forget. The cost is that an *untracked* module file does not exist as far
as the flake is concerned and nothing fails; `scripts/check-systems.sh` refuses
that case. Categories:

- `core/` - machine foundation that has no natural app (boot, networking,
  users, Nix settings, `nh`, power, audio, tools).
- `desktop/` - the session and how it looks: `niri`, `noctalia`, `appearance`,
  `sddm`, `kde`.
- `apps/` - one app or concern per folder, including `photocraft`.
- `services/` - background daemons and device glue: `syncthing`, `kdeconnect`,
  `storage`.
- `bundles/` - grouped package lists and default choices, with no per-app folders:
  `default-apps`, `desktop-apps`.
- `optional/` - off by default; a host opts in with `my.<feature>.enable`.

`core/` is the exception to the folder rule: it holds one file per concern
(`boot.nix`, `networking.nix`, ...) and has no per-feature `system.nix`/`home.nix`
split.

A feature never splits across categories: its `system.nix`, `home.nix` and
`config/` stay in one folder. Per-machine differences live in `hosts/<host>/`.

## Toggles

Every feature has an `enable` option, off by default. Modules are imported
permanently - by file name through `lib/modules.nix`, so there is no import list
to edit at all - and a feature is turned on or off only through its option, never
by removing an import. This is the whole point of the option approach: no host
can silently drop a feature by deleting an import.

- Every switch is `my.<feature>.enable`. There is a single namespace:
  `modules/optional/` only marks the features that are off by default.
- `configuration.nix` declares every switch with `lib.mkEnableOption` and sets
  its default in the same block, as a by-hand lookup table. Shared features use
  `lib.mkDefault true`, the rest `lib.mkDefault false`. `lib.mkDefault` is
  essential: it makes the value only a *default*, so a host can still override
  it; a plain `= true` there would conflict with a host's `= false`. A feature
  with nothing to configure on the system side has no `system.nix` - the
  declaration here is all it needs.
- `hosts/<host>/default.nix` carries only the deltas, as plain `= true`/`= false`
  (normal priority beats `lib.mkDefault`). Features wanted on both machines stay in
  `configuration.nix`; only real per-machine differences live in the host file.
- A single package inside a feature that one host does not want gets its own
  nested switch (`my.dev.godot.enable`, `my.desktopApps.davinciResolve.enable`).
  It is defaulted on in `configuration.nix` and its gate also tests the parent
  switch, so turning the feature off can never leave the package behind. This is
  what keeps hostname checks like the old `ConditionHost = "desk"` out of the
  modules.
- A feature with both halves is gated by one switch: `system.nix` uses
  `lib.mkIf cfg.enable`; `home.nix` reads the same system option through `osConfig`
  (`lib.mkIf osConfig.my.<feature>.enable`). Home-manager runs as a NixOS module, so
  `osConfig` exposes the merged system option tree.

Because the option default is off, a feature mentioned nowhere is off.
`configuration.nix` is the one place to look an option up.

| Group | Switch | Enabled in |
|---|---|---|
| core (niri, noctalia, zsh, nvim, gaming, ...) | `my.<feature>.enable` | `configuration.nix` (on), overridden per host |
| kde | `my.kde.enable` | `hosts/desk/default.nix` (test) and `hosts/vivobook/default.nix` |
| photocraft | `my.photocraft.enable` | `hosts/desk/default.nix`, `hosts/vivobook/default.nix` |
| printing | `my.printing.enable` | `hosts/vivobook/default.nix` |
| kdeconnect | `my.kdeconnect.enable` | `hosts/desk/default.nix` |
| optional (flatpak, minecraft, ollama, openrgb, tmux) | `my.<feature>.enable` | `hosts/<host>/default.nix` |

`my.sddm.wallpaper` and `my.sddm.forceLastUser` are value options, not switches.
`my.dotfiles.live` and `my.zen.package` are per-user options declared in
home-manager, not host switches.

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

A second user can set `my.dotfiles.live = false` (declared in
[`lib/user-options.nix`](../lib/user-options.nix)). nvim and ghostty are then
copied into the store instead of symlinked to the owner's repo, so they do not
depend on `/home/descryx` being readable. KDE is not symlinked at all: KDE
rewrites its rc files atomically, which replaces symlinks. The stable keys are
declared through plasma-manager in `users/lena/plasma.nix`; runtime edits stay
in the real files and can be captured with `rc2nix` when they should go into
git.

KDE's GTK bridge also writes dconf values (icon theme, font) when a KDE session
logs in, and dconf wins over `gtk-3.0/settings.ini` for GTK apps.
`modules/desktop/appearance/home.nix` pins the owner's values with
`dconf.settings`, so a rebuild restores them. lena uses Thunar
(`environment.plasma6.excludePackages` drops Dolphin), and her Ghostty profile
sets `my.ghostty.windowDecorations = true` to get `window-decoration = auto`.

lena's Win11 look is packaged from two GPL-3.0 repos in
`users/lena/theme/` and linked into her home: the look-and-feel, Plasma style,
Aurorae decoration, color scheme and the black/dark icon set. The Windows
wallpaper, Kvantum theme and KDE Store dependency list are not shipped; the
look-and-feel defaults are patched to Breeze for those pieces.

## Hosts & deploy

- Filesystems are mounted by label, not UUID (the labels are in
  [NOTES.md](NOTES.md)), so no disk IDs are in the repo.
- There is no disko integration. New machines are partitioned manually and use
  label-based `fileSystems`; the Vivobook runbook is
  [FAMILY.md](FAMILY.md).
- The Vivobook runs 26.05 stable with `linuxPackages_latest` (7.3) because the
  default 6.18 LTS has no MT7902 driver. `hardware.enableRedistributableFirmware`
  provides the Wi-Fi/Bluetooth/GPU firmware. It keeps 5 system generations
  (`configurationLimit` and `nh clean --keep 5`).
- On the Vivobook, `descryx` is a maintenance account reachable over SSH and a
  TTY but hidden from SDDM with `services.displayManager.hiddenUsers`; lena is
  the only visible user. The theme's index-0 default then selects lena.
- The SDDM astronaut theme is patched to preselect index 0 instead of
  `model.lastIndex`. On desk/t480 that is niri + descryx; on the Vivobook the only
  session is Plasma and the only visible user is lena. Do not log descryx into
  Plasma on desk: KWin writes a display config into his home and can move the
  monitor off-screen; use lena for Plasma.
- `hosts/desk/plasma.nix` exists only so a second user can log into KDE on desk.
  It pins `defaultSession = "niri"`, the greeter compositor back to `weston`,
  the owner's fonts/pinentry, and SDDM's last-user/last-session memory.
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
- The Vivobook host carries the `descryx` SSH **public** key; public keys are not
  secrets and are safe in the repo. Private keys and passwords never are.
- Hooks guard it: `noctalia-scrub` strips credential fields and refuses a write
  that still has one, `detect-private-keys` catches PEM keys, and `ripsecrets` is
  the catch-all scanner.
