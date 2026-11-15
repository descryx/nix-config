# Common commands

Quick reference for this repo. Working notes are in [NOTES.md](NOTES.md);
architecture in [ARCHITECTURE.md](ARCHITECTURE.md).

`programs.nh` sets `NH_FLAKE=/home/descryx/nix-config`, so `nh` works from any
directory; it picks the config from the running hostname.

> **Laptop rule:** never run `nix flake update` (or change `flake.lock`) on `t480`
> or `vivobook`. Update on `desk`, then push and pull.

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

Build parallelism is capped per host (`max-jobs` in `hosts/<host>/default.nix`,
`cores` in `modules/core/nix-settings.nix`) so a build cannot exhaust RAM. Build
without activating:

```sh
nix build .#nixosConfigurations.desk.config.system.build.toplevel
nix build .#nixosConfigurations.t480.config.system.build.toplevel
nix build .#nixosConfigurations.vivobook.config.system.build.toplevel
```

## Vivobook / stable host

Vivobook is on 26.05 stable with `linuxPackages_latest` for the MT7902 Wi-Fi.
Build and test it on desk before touching the laptop:

```sh
nix build .#nixosConfigurations.vivobook.config.system.build.toplevel
```

### Testing the config in a VM

The VM is the quickest way to see a desktop change without touching the laptop.
It builds the same config and auto-logs in as lena (VM-only setting):

```sh
cd /tmp/opencode
run="$(nix build --no-link --print-out-paths .#nixosConfigurations.vivobook.config.system.build.vm)/bin/run-vivobook-vm"
"$run"
```

- Run it from a scratch directory: QEMU writes `vivobook.qcow2` (20 GiB sparse)
  into the current directory. Delete it for a clean boot, or set `NIX_DISK_IMAGE`
  to another path.
- 4 GiB RAM, 4 cores, 20 GiB disk (`virtualisation.vmVariant` in
  `hosts/vivobook/default.nix`).
- Tests: Plasma start, SDDM and theme assets, Thunar, Ghostty, the apps, the
  clock and calendar plugin UI, and evaluation/activation errors.
- Does not test: Wi-Fi and Bluetooth (MT7902), GPU, audio, suspend, the printer,
  and Google OAuth (needs a real browser session). Those run on the laptop.

### Remote access

Only the Vivobook runs sshd; desk and t480 do not, so the direction is always
desk -> laptop. It is key-only (`AllowGroups wheel`, no passwords), so only
`descryx` can connect; lena cannot, by design.

Find the address on the laptop (`ip -4 -br addr show scope global`). There is no
Avahi, so `<host>.local` does not resolve; use the IP:

```sh
ssh descryx@<ip>                          # interactive; accept the host key once
ssh -o BatchMode=yes descryx@<ip> true     # connectivity check, no prompt
```

A command-only session gets no TTY, so `ssh host 'sudo ...'` fails with
"a password is required". Add `-t`:

```sh
ssh -t descryx@<ip> 'sudo nh os switch'
```

Everyday scenarios:

- **Update the laptop**: edit and commit on desk, push, then
  `ssh -t descryx@<ip>`, `cd ~/nix-config`, `git pull`, `sudo nh os switch`.
  Log lena out first; KDE reads her rc files at login.
- **Build on desk, install on the laptop** for long builds:
  `nix copy --to ssh-ng://descryx@<ip> "$(nix build --no-link --print-out-paths
  .#nixosConfigurations.vivobook.config.system.build.toplevel)"`, then `sudo nh
  os switch` on the laptop. It still evaluates, but everything is already in the
  store.
- **Files for lena**: `scp` them to `/tmp`, then
  `ssh -t descryx@<ip> 'sudo mv /tmp/x /home/lena/... && sudo chown -R
  lena:users /home/lena/...'`. `/home/lena` is 0700, so descryx cannot write
  there directly. rsync is not installed on the laptop.
- **Run something as lena**: `ssh -t descryx@<ip> 'sudo -u lena -i <command>'`,
  for example the opencode session import.
- **Her clipboard**: `wl-copy` has to run inside her session with her
  `XDG_RUNTIME_DIR` and `WAYLAND_DISPLAY`; the exact command is in
  [FAMILY.md](FAMILY.md).
- **Logs**: `ssh descryx@<ip> 'systemctl --failed; journalctl -b -p warning | tail'`.
- **If remote access is down**: Ctrl+Alt+F3 on the laptop gives a text console
  for descryx; her Plasma session stays on its own VT.
- **From outside the LAN**: not configured. There is no VPN and no port
  forwarding, and port 22 should not be exposed.

Terminfo trap: from Ghostty the session gets `TERM=xterm-ghostty`, which has no
entry for descryx on the laptop, so git's pager fails with `unknown terminal
type`. Use `TERM=xterm-256color ssh ...` or `git --no-pager`.

The key is the one committed in `hosts/vivobook/default.nix`; a second desk or
recovery key is added there, never by appending to the laptop's
`authorized_keys` (NixOS rewrites that file on activation).

## Checks

`nix flake check` evaluates all hosts and builds the pre-commit check, but does
not instantiate the systems. For derivation-time errors (e.g. a moved path):

```sh
./scripts/check-systems.sh   # all hosts, one nix eval each
```

`nix fmt` formats Nix files (treefmt: nixfmt + deadnix). `.envrc` loads the dev
shell via direnv and its `shellHook` installs the git hooks (nixfmt, deadnix,
statix, check-toml, detect-private-keys, noctalia-scrub, ripsecrets). Run them by
hand with `nix develop -c pre-commit run --all-files`.

## KDE profile (lena's laptop)

lena exists only on the Vivobook; desk and t480 are the owner's niri machines.
Validate her profile with `nix build
.#nixosConfigurations.vivobook.config.system.build.vm` and the VM (it autologs in
as lena) instead of installing Plasma on desk.

Files: `users/lena/plasma.nix` holds the high-level plasma-manager options
(keyboard layouts, wallpaper, look-and-feel); `plasma-desktop.nix` holds the
settings captured from her session; `theme.nix` packages the Win11 assets. Thunar
is her file manager, Dolphin is excluded, and Ghostty uses native KDE decorations
(`my.ghostty.windowDecorations`). Home-manager generations are per user, the
system generation is shared with descryx. No password is stored in the repo.

### Editing KDE live

Plasma-manager is the source of truth, but the GUI is the fastest way to find a
setting: change it live, export the change, merge it, switch. Settings changed in
System Settings survive a switch anyway (the writer only updates the keys
declared in Nix and preserves the rest, because `overrideConfig` is off), but
they are not reproducible and are lost on a reinstall. Capture what is worth
keeping.

The loop, on the Vivobook, from the repo, as descryx (`ssh -t` from desk for the
`sudo` prompt):

```sh
./scripts/kde-export.sh save     # baseline; right after a switch
# change ONE thing in lena's Plasma session
./scripts/kde-export.sh diff | cat
```

`save` snapshots the files rc2nix reads into `~/.cache/kde-export/base`; `diff`
takes a second snapshot, renders both with rc2nix pinned to `flake.lock`, and
prints a unified diff. The first run downloads and builds rc2nix.

Merge the `+` lines on desk, in `users/lena/plasma-desktop.nix`:

- `shortcuts.*` -> `shortcuts.<group>.<action> = "key";` or a list.
- `configFile.*` -> `configFile."<file>"."<section>"."<key>" = value;`, under the
  existing entry for that file.
- If the file is generated from a high-level option, change the option instead.
  `kxkbrc` comes from `input.keyboard.layouts`, so layout display names belong in
  `plasma.nix`; a `configFile` entry for the same file fights the option.
- Drop: `"kwin/$InverseAction"` (KWin's built-in inverse table; never compact it
  into `shortcuts.kwin`, which only accepts action -> key bindings), activity
  UUIDs, screen/output IDs, Dolphin, Logitech, generated `kwinrulesrc` rules.

Adding a file to `configFile` for the first time is safe: the writer reads the
existing file and only sets the declared keys. That changes if `overrideConfig`
is ever enabled - it deletes the listed files and rebuilds them from Nix, so
undeclared keys would then vanish.

What the export does not cover: the panel/bar
(`plasma-org.kde.plasma.desktop-appletsrc`), screen layout, and KWin window rules
(`kwinrulesrc`). Those stay live. A panel is only reproducible with
`programs.plasma.panels`, which rebuilds the appletsrc on activation and
therefore discards live panel edits; do that deliberately once the layout is
settled, not while iterating.

Then the normal cycle:

```sh
# desk
nix fmt
nix flake check
./scripts/check-systems.sh
git commit -am "..."   # or split
git push
```

```sh
# laptop
cd ~/nix-config
git pull
sudo nh os switch
```

Log lena out and back in afterwards: `kcminputrc`, `kxkbrc`, shortcuts and
look-and-feel are read at login. Then run `save` again so the baseline includes
what you just merged, otherwise the next `diff` repeats it.

### Gotchas

- Do not run the script with `sudo`. It elevates internally; under `sudo` the home
  is `/root`, so it finds no baseline.
- `git diff` on the laptop is expected to be empty. The export lives in
  `~/.cache/kde-export`, not in the repo.
- Over `ssh` from Ghostty, `TERM=xterm-ghostty` has no terminfo entry for
  descryx on the laptop, and git's pager fails with `unknown terminal type`. Use
  `git --no-pager diff` or `export TERM=xterm-256color`.
- The repo on the laptop is read-only in practice: edit and commit on desk, pull
  and switch on the laptop. Never update `flake.lock` there.

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
