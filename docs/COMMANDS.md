# Common commands

Quick reference for this repo. Working notes are in [NOTES.md](NOTES.md);
architecture in [ARCHITECTURE.md](ARCHITECTURE.md).

`programs.nh` sets `NH_FLAKE=/home/descryx/nix-config`, so `nh` works from any
directory; it picks the config from the running hostname.

> **Laptop rule:** never run `nix flake update` (or change `flake.lock`) on `t480`.
> Update on `desk`, then push and pull.

## Rebuild / switch

`nixos-rebuild` is replaced by `nh`:

| Command | Effect |
|---|---|
| `nh os switch` | build + activate now, and make it the boot default |
| `nh os boot` | build + make it the boot default (no live activation) |
| `nh os test` | build + activate now, not persisted to boot |
| `nh os build` | build only (no activation) |
| `nh os rollback` | roll back to the previous generation |
| `nh os info` | list system generations |

For filesystem/mount changes (`fileSystems` devices), use `nh os boot` then
reboot, not `nh os switch`: it tries to remount `/home` and `/` live and fails
with `failed to restart home.mount`.

Build parallelism is capped per host in `hosts/<host>/nix-settings.nix`
(`max-jobs`/`cores`) so a build cannot exhaust RAM. Build without activating:

```sh
nix build .#nixosConfigurations.desk.config.system.build.toplevel
nix build .#nixosConfigurations.t480.config.system.build.toplevel
```

## Checks

`nix flake check` evaluates both hosts and builds the pre-commit check, but does
not instantiate the systems. For derivation-time errors (e.g. a moved path):

```sh
./scripts/check-systems.sh   # both hosts, one nix eval each
```

`nix fmt` formats Nix files (treefmt: nixfmt + deadnix). `.envrc` loads the dev
shell via direnv and its `shellHook` installs the git hooks (nixfmt, deadnix,
statix, check-toml, detect-private-keys, noctalia-scrub, ripsecrets). Run them by
hand with `nix develop -c pre-commit run --all-files`.

## Navigation

```sh
tree -C -L 2 modules    # the module tree
```

`desmod` fuzzy-picks a `modules/<category>/<feature>/` (fd + fzf) and `cd`s there;
`desmodv` opens the pick in nvim, `desmody` in yazi.

## Commit messages

Format: `type(scope): summary`, lowercase imperative with no trailing period.
`scope` is where the change is (`modules/<category>/<name>`, `flake`, `hosts`,
`docs`); add a body when the why isn't obvious. Types: `feat`, `fix`, `chore`,
`refactor`, `docs` (plus `perf`, `style`, `test`, `build`, `ci`, `revert`). Use
`feat`/`fix` if a user can tell something changed, otherwise `chore`/`refactor`.

## Noctalia config & secrets

The tracked baseline `modules/desktop/noctalia/config/noctalia/noctalia-config.toml`
sits under the app-managed `~/.local/state/noctalia/settings.toml` (per-machine GUI
overrides and the plugin API keys, which stay outside the repo).

After changing Noctalia in the GUI, regenerate the baseline with the wrapper (do
not redirect `export merged` by hand):

```sh
./scripts/noctalia-export.sh             # export -> scrub -> check -> write
./scripts/noctalia-export.sh --dry-run   # diff only
```

`scripts/noctalia-scrub.sh` strips credential fields and the write is refused if a
sensitive field remains; `ripsecrets` is the catch-all scanner.

## Updating pinned packages

Custom packages are exposed as `packages.<system>` in `flake.nix`, so they build
and update without touching a host:

```sh
nix build .#niri-zoom                   # the package alone
nix develop -c nix-update niri-zoom --flake --version=branch   # new rev + hash
```

`nix-update` is in the dev shell. It finds the `.nix` file through the
derivation's `src` and rewrites `version`, `rev` and `hash` in place; check the
result with `nix build .#<name>` before the usual checks. Packages whose upstream
has no releases (commit-tracked ones) need `--version=branch`, and packages with
non-standard URLs need `--url`.

Doing it by hand, change `rev` and `version` together, then let the build tell you
the hash:

```sh
nix store prefetch-file --unpack --json https://github.com/<owner>/<repo>/archive/<rev>.tar.gz
```

`fetchFromGitHub` takes either `rev` or `tag`, not both (current nixpkgs enforces
this), and its `hash` is the sha256 of the *unpacked* tree - the `--unpack` flag
above is what makes the two tools agree.

Upstream meson projects with `auto` options get `-Dauto_features=enabled` from
nixpkgs, so a missing optional library is a hard configure error rather than a
silently disabled feature. Pin what the package should ship in `mesonFlags`
instead of relying on `auto`.

## Noctalia plugin dependencies

Most plugin dependencies are plain nixpkgs packages in
`modules/desktop/noctalia/home.nix`. `localsend-plus` is the exception: its
`localsend-controller` helper is built from the plugin sources, pinned in
[`modules/desktop/noctalia/localsend-controller.nix`](../modules/desktop/noctalia/localsend-controller.nix)
to the community-plugins revision that ships it.

Noctalia pulls plugin sources itself (startup and every 6h), so a plugin release
can ask for a newer controller than the packaged one. The panel then reports
"old controller" and refuses to start the daemon; nothing else breaks. Compare and
bump:

```sh
grep -m1 '^version' ~/.local/state/noctalia/plugins/materialized/community/localsend-plus/controller/Cargo.toml
```

Change `rev`, `version`, `src.hash` and `cargoHash` in the `.nix` file together;
`nix build` prints the correct hashes on mismatch.
