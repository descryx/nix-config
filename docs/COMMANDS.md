# Common commands

Quick reference for this repo. [docs/NOTES.md](NOTES.md) has the longer
tutor-style docs (new machine, disko); this file is the cheat-sheet.

`programs.nh` sets `NH_FLAKE=/home/descryx/nix-config`, so `nh` works from any
directory.

> **Laptop rule:** never run `nix flake update` (or change `flake.lock`) on `t480`.
> Lock and update on `desk`, then push and pull.

## Rebuild / switch

`nixos-rebuild` is replaced by `nh`.

| Command | Effect |
|---|---|
| `nh os switch` | build + activate now, and make it the boot default |
| `nh os boot` | build + make it the boot default (no live activation) |
| `nh os test` | build + activate now, not persisted to boot |
| `nh os build` | build only (no activation) |
| `nh os switch -n` | dry-run: show what it would do |
| `nh os switch -a` | ask for confirmation first |
| `nh os rollback` | roll back to the previous generation |
| `nh os info` | list system generations |

For filesystem/mount changes (`fileSystems` devices), use `nh os boot` then
reboot. Do not use `nh os switch`: it tries to remount `/home` and `/` live and
fails with `failed to restart home.mount`.

Both hosts build the same way; `nh` picks the config from the running hostname.
Build one without activating:

```sh
nix build .#nixosConfigurations.desk.config.system.build.toplevel
nix build .#nixosConfigurations.t480.config.system.build.toplevel
```

## Flake, formatting, checks

| Command | Effect |
|---|---|
| `nix flake check` | evaluate both hosts + build the pre-commit check (not the systems) |
| `nix fmt` | format Nix files (treefmt: nixfmt + deadnix) |
| `nix flake update` | update all inputs (desk only) |
| `nix flake update <input>` | update one input (desk only) |
| `nix flake metadata` | show the locked inputs/revs |

## Dev shell / pre-commit hooks

`.envrc` contains `use flake`, so direnv loads the dev shell and its `shellHook`
installs the git hooks (nixfmt, deadnix, statix, check-toml, detect-private-keys,
noctalia-scrub, ripsecrets).

```sh
direnv allow                              # once per repo per machine, then auto-loads
nix develop                               # or enter the dev shell manually
nix develop -c pre-commit run --all-files # run all hooks by hand
```

The hooks run on `git commit`. If you must skip once, `git commit --no-verify`.

## Generations & cleanup

`programs.nh.clean` runs daily and keeps 10 generations (`modules/system/nh.nix`).

```sh
nh clean all --keep 10        # trim all profiles + gc the store
nh clean all --keep 10 --dry  # preview only
nh os info                    # list system generations
```

## Git workflow

New files must be tracked before a flake build can see them:

```sh
git add <new-file>
git status
git diff
git commit -m "…"
git push
```

On the other machine: `git pull`, then `nh os switch`.

### Commit messages

Format: `type(scope): summary`, lowercase imperative summary with no trailing
period. `scope` is where the change is (`modules/<category>/<name>`, `flake`, `hosts`,
`docs`). Add a body when the why isn't obvious.

Common types: `feat`, `fix`, `chore`, `refactor`, `docs`, plus `perf`, `style`,
`test`, `build`, `ci`, `revert`. If a user can tell something changed, use
`feat`/`fix`; if only repo internals changed, use `chore`/`refactor`/`build`.

The full list is printed by the `commitConvention` shell function.

## New machine (disko)

```sh
./scripts/provision.sh <host> /dev/disk/by-id/<disk>   # ERASES the disk
```

Read the tutor in [NOTES.md](NOTES.md) first. `scripts/provision.sh` is an
untested draft.

## Disks & labels

Live hosts mount filesystems by label (`/dev/disk/by-label/<name>`), not UUID, so
no disk IDs live in the repo (see [NOTES.md](NOTES.md)).

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID   # current labels + UUIDs
ls -l /dev/disk/by-label/

sudo btrfs filesystem label /               nixos       # root btrfs
sudo fatlabel /dev/disk/by-uuid/<ESP-UUID>  boot        # EFI (vfat); unmount /boot if busy
sudo ntfslabel /dev/disk/by-uuid/<UUID>     old-ssd-2   # unmount the NTFS volume first

sudo mount -a                          # mount whatever the labels now resolve to
```

`ntfslabel` ships in `ntfs3g`, which isn't installed by default (run it via
`nix shell nixpkgs#ntfs3g`). Data-disk mounts are `nofail`, so absent disks are
skipped.

## Services in this repo

| Service | Scope | Inspect |
|---|---|---|
| syncthing | system service, runs as `descryx` | `systemctl status syncthing`, `journalctl -u syncthing` |
| undershell | user service, desk only (`ConditionHost`) | `systemctl --user status undershell`, `journalctl --user -u undershell` |
| easyeffects | user service | `systemctl --user status easyeffects` |
| udiskie | user service | `systemctl --user status udiskie` |
| niri-zoomd | user service | `systemctl --user status niri-zoomd` |
| minecraft-server | system service, not auto-started | `systemctl status minecraft-server` |

Useful app CLIs:

```sh
undershell msg status                 # widgets / fps / depth state
undershell msg edit                   # on-screen editor on/off
undershell msg quit

syncthing device-id                   # this machine's ID, for the Syncthing UI
noctalia msg panel-toggle <panel>     # toggle a Noctalia panel
```

## Noctalia config & secrets

Noctalia layers config: the tracked baseline
`modules/desktop/noctalia/config/noctalia/noctalia-config.toml` sits under the app-managed
`~/.local/state/noctalia/settings.toml` (per-machine GUI overrides, and the plugin
API keys). The keys stay in `settings.toml`, outside the repo.

After changing Noctalia in the GUI, regenerate the baseline with the wrapper.
Don't redirect `export merged` into the file by hand:

```sh
./scripts/noctalia-export.sh             # export -> scrub -> check -> write
./scripts/noctalia-export.sh --dry-run   # diff only
```

It exports to a temp file, strips credential fields, and refuses to overwrite the
baseline if a sensitive field remains.

- `scripts/noctalia-scrub.sh` removes credential fields (`api_key`, `password`,
  `token`, `secret`, `refresh_token`, `client_secret`) and never removes anything
  else.
- `noctalia-scrub --check` (the pre-commit hook) fails if a non-empty credential is
  present, or if a field it only reports is found. It edits nothing.
- The field lists are a denylist, so a hit means "review this", not "definitely a
  leak". Matches are anchored to a whole key name, so `password_style` or
  `secret_store` don't match. Tune the lists in the script header.
- `check-toml`, `detect-private-keys` and `ripsecrets` cover TOML syntax, PEM keys
  and general secrets.

## Search

```sh
nh search <query>            # packages (search.nixos.org)
nh search options <query>    # NixOS / home-manager options
nh search offline <query>    # local nix-index database
```
