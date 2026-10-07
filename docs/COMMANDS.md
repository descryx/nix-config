# Common commands

Cheat-sheet for this repo. `docs/NOTES.md` has the longer tutor-style docs
(new-machine/SSH/disko); this file is the quick reference.

`programs.nh` sets `NH_FLAKE=/home/descryx/nix-config`, so `nh` commands work
from any directory.

> **Laptop rule:** never run `nix flake update` (or otherwise change `flake.lock`)
> on `t480`. Lock/update on `desk`, then push and pull.

## Contents

- [Rebuild / switch](#rebuild--switch)
- [Flake, formatting, checks](#flake-formatting-checks)
- [Dev shell / pre-commit hooks](#dev-shell--pre-commit-hooks)
- [Generations & cleanup](#generations--cleanup)
- [Git workflow](#git-workflow)
  - [Commit messages](#commit-messages)
- [New machine (disko)](#new-machine-disko)
- [Services in this repo](#services-in-this-repo)
- [Noctalia config & secrets](#noctalia-config--secrets)
- [Search](#search)

---

## Rebuild / switch

`nixos-rebuild` is replaced by `nh`.

| Command | Effect |
|---|---|
| `nh os switch` | build + activate now **and** make it the boot default |
| `nh os boot` | build + make it the boot default (no live activation) |
| `nh os test` | build + activate now, **not** persisted to boot |
| `nh os build` | build only (no activation) |
| `nh os switch -n` | dry-run: show what it would do |
| `nh os switch -a` | ask for confirmation first |
| `nh os rollback` | roll back to the previous generation |
| `nh os info` | list system generations |

> **Filesystem/mount changes** (`fileSystems` devices, e.g. moving a host to
> `by-label`): apply with `nh os boot` then reboot. Do **not** use `nh os switch`
> for these — it tries to remount `/home`/`/` live and fails (`failed to restart
> home.mount`). The new mount is used at the next boot.

Both hosts are built the same way; the host is chosen by the flake output name
(`desk`/`t480`) which `nh` derives from the running hostname.

Build a specific host/system without activating:

```sh
nix build .#nixosConfigurations.desk.config.system.build.toplevel
nix build .#nixosConfigurations.t480.config.system.build.toplevel
```

---

## Flake, formatting, checks

| Command | Effect |
|---|---|
| `nix flake check` | evaluate both hosts + build the pre-commit check (does **not** build the systems) |
| `nix fmt` | format Nix files (treefmt: nixfmt + deadnix) |
| `nix flake update` | update **all** inputs (**desk only**) |
| `nix flake update <input>` | update one input (**desk only**) |
| `nix flake metadata` | show the locked inputs/revs |

---

## Dev shell / pre-commit hooks

`.envrc` contains `use flake`, so `direnv` (with `nix-direnv`) loads the devShell
and its `shellHook` installs the git hooks (nixfmt, deadnix, statix, check-toml,
detect-private-keys, noctalia-scrub, ripsecrets).

```sh
direnv allow                              # once per repo per machine, then auto-loads
nix develop                               # or enter the devShell manually
nix develop -c pre-commit run --all-files # run all hooks by hand
```

The hook runs automatically on `git commit`. To bypass once (use sparingly):
`git commit --no-verify`.

---

## Generations & cleanup

`programs.nh.clean` runs daily and keeps 10 generations (`modules/system/nh.nix`).
Manual cleanup:

```sh
nh clean all --keep 10        # trim all profiles + gc the store
nh clean all --keep 10 --dry  # preview only
nh os info                    # list system generations
```

---

## Git workflow

New files must be tracked before a flake build can see them:

```sh
git add <new-file>
git status
git diff
git commit -m "…"
git push
```

On the other machine: `git pull` then `nh os switch`.

### Commit messages

Format: `type(scope): summary` — a small [Conventional Commits](https://www.conventionalcommits.org)
subset, not the whole spec.

- `scope` — where the change is: a `modules/<name>/` folder (e.g. `desktop-apps`,
  `gaming`, `noctalia`) or a top-level area (`flake`, `hosts`, `docs`). Not the
  category of app. Omit only if the change is truly repo-wide.
- `summary` — imperative mood, lowercase, no trailing period, ~72 chars.
- Add a blank line + body when the *why* isn't obvious (e.g. what was removed).

Types:

- `feat` — new user-visible capability, incl. swapping one tool for another.
  e.g. `feat(desktop-apps): replace kdenlive with davinci-resolve`
- `fix` — fixes a bug. e.g. `fix(noctalia): stop panel-toggle crash`
- `chore` — maintenance, no user-visible change (deps, tooling).
  e.g. `chore(flake): update flake inputs`
- `refactor` — internal rewrite, same behaviour. e.g. `refactor(system): split boot module`
- `docs` — docs only. e.g. `docs(commands): document commit convention`
- `perf` — makes something faster (not a new `feat`).
- `style` — formatting/whitespace only, no behaviour change (nixfmt already handles Nix, so rare).
- `test` — adds or fixes tests.
- `build` — build system / dependencies (`flake.lock`, flake inputs).
- `ci` — CI / automation config.
- `revert` — undoes a previous commit.

Rule: if a user can tell something changed → `feat`/`fix`; if only repo internals
changed → `chore`/`refactor`/`build`.

In a shell, commitConvention prints this section (rendered with glow).

---

## New machine (disko)

```sh
./scripts/provision.sh <host> /dev/disk/by-id/<disk>   # ERASES the disk
```

Read the tutor in `docs/NOTES.md` first. `scripts/provision.sh` is an untested draft.

---

## Disks & labels

Live hosts mount filesystems by label (`/dev/disk/by-label/<name>`), not UUID, so
no disk identifiers live in the repo (see [NOTES.md](NOTES.md) → "Filesystem
labels (live hosts)").

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID   # current labels + UUIDs
ls -l /dev/disk/by-label/

sudo btrfs filesystem label /               nixos       # root btrfs
sudo fatlabel /dev/disk/by-uuid/<ESP-UUID>  boot        # EFI vfat (unmount /boot if busy)
sudo ntfslabel /dev/disk/by-uuid/<UUID>     old-ssd-2   # unmount the NTFS volume first

sudo mount -a                          # mount whatever the labels now resolve to
```

`ntfslabel` ships in `ntfs3g` (not installed by default — run it via
`nix shell nixpkgs#ntfs3g`). Data-disk mounts are `nofail`, so unlabelled or
absent disks are simply skipped.

---

## Services in this repo

| Service | Scope | Inspect |
|---|---|---|
| syncthing | system service, runs as `descryx` | `systemctl status syncthing`, `journalctl -u syncthing` |
| undershell | **user** service, **desk only** (`ConditionHost`) | `systemctl --user status undershell`, `journalctl --user -u undershell` |
| easyeffects | user service | `systemctl --user status easyeffects` |
| udiskie | user service | `systemctl --user status udiskie` |
| niri-zoomd | user service | `systemctl --user status niri-zoomd` |
| minecraft-server | system service, not auto-started (`wantedBy = mkForce [ ]`) | `systemctl status minecraft-server` |

Useful app CLIs:

```sh
undershell msg status                 # widgets / fps / depth state
undershell msg edit                   # on-screen editor on/off
undershell msg quit

syncthing device-id                   # this machine's ID, for pairing in the Syncthing UI
noctalia msg panel-toggle <panel>     # toggle a Noctalia panel
```

---

## Noctalia config & secrets

Noctalia v5 layers its config: the tracked baseline
`modules/noctalia/config/noctalia/noctalia-config.toml` (declarative) sits under the
app-managed `~/.local/state/noctalia/settings.toml` (GUI overrides, per machine).
**Plugin API keys live in `settings.toml`** — outside the repo — and are entered
once per machine in the Settings UI.

After changing Noctalia in the GUI, regenerate the tracked baseline with the
wrapper — do **not** redirect `export merged` into the file by hand:

```sh
./scripts/noctalia-export.sh             # export -> scrub -> check -> write
./scripts/noctalia-export.sh --dry-run   # show the diff only

# review + commit
git diff -- modules/noctalia/config/noctalia/noctalia-config.toml
git add modules/noctalia/config/noctalia/noctalia-config.toml && git commit
```

`noctalia-export.sh` exports to a temp file, runs the scrub, and refuses to
overwrite the baseline if anything sensitive remains (the tracked file is left
untouched on failure).

- `scripts/noctalia-scrub.sh` removes credential fields (`api_key`, `password`,
  `token`, `secret`, `refresh_token`, `client_secret`). It never removes anything
  else.
- `scripts/noctalia-scrub.sh --check` (what the pre-commit hook runs) exits
  non-zero if a non-empty credential is present, or if another sensitive field the
  script only *reports* (never deletes) is found. No file is edited.
- **Tuning / false positives:** the field lists are a denylist, so a `--check` hit
  means "review this", not "definitely a leak". Matches are anchored to an exact key
  name (`^<name> =`), so functional keys like `password_style` or `secret_store`
  don't match. If a genuine value is ever flagged, adjust the lists; report-only
  fields never block a commit.
- `check-toml` validates the TOML syntax and `detect-private-keys` catches PEM
  private keys; `ripsecrets` is a catch-all secret scanner.

---

## Search

```sh
nh search <query>            # packages (search.nixos.org)
nh search options <query>    # NixOS / home-manager options
nh search offline <query>    # local nix-index database
```

---

## See also

- [`README.md`](../README.md) — overview and how to adapt the config.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — how the repo is structured.
- [`CREDITS.md`](CREDITS.md) — acknowledgements and third-party notices.
- [`NOTES.md`](NOTES.md) — new-machine (SSH + disko) tutors and scratch notes.
