# nix-config

My personal, flake-based [NixOS](https://nixos.org) + [home-manager](https://github.com/nix-community/home-manager)
configuration for two machines, pinned in `flake.lock`, with dotfiles symlinked
out-of-store so they stay live-editable.

## Table of contents

- [Overview](#overview)
- [Screenshots](#screenshots)
- [Hosts](#hosts)
- [Highlights](#highlights)
- [Repository layout](#repository-layout)
- [Using / adapting this config](#using--adapting-this-config)
- [Development / validation](#development--validation)
- [AI assistance & scope](#ai-assistance--scope)
- [Credits](#credits)
- [License](#license)

## Overview

Everything about this system is declared in Nix: packages, services, the
compositor, and most app configs. A few large or frequently hand-edited configs
live as ordinary dotfiles inside their feature folder (`modules/<feature>/config/`),
symlinked into place with `mkOutOfStoreSymlink` so editing them does not need a
rebuild. The design is
described in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md); the file tree is in
[docs/structure.md](docs/structure.md).

Two hosts are configured: a desktop (`desk`) and a ThinkPad T480 (`t480`).
Secrets are kept out of the repo: Noctalia's plugin keys live per-machine in
`~/.local/state/noctalia/settings.toml` (see
[docs/COMMANDS.md](docs/COMMANDS.md) → "Noctalia config & secrets"). A secrets
manager for future system-level secrets is deferred to
[docs/NOTES.md](docs/NOTES.md) → "Secrets & keys (future plan)".

## Screenshots

<img src="screenshots/desktop-screen-1.png" width="100%" alt="desktop screenshot 1">

<details>
  <summary>More screenshots</summary>
  <br>
  <p align="center">
    <img src="screenshots/desktop-screen-3.png" width="49%" alt="desktop screenshot 2">
    <img src="screenshots/niri-anim-1.gif" width="49%" alt="niri animation">
  </p>
</details>

## Hosts

**Username:** `descryx`

| Device | Hostname | Hardware | Config |
|--------|----------|----------|--------|
| Desktop | `desk` | NVIDIA + Intel | [`hosts/desk/`](hosts/desk/) |
| Laptop  | `t480` | ThinkPad T480 (Intel) | [`hosts/t480/`](hosts/t480/) |

## Highlights

- **Desktop** — [Niri](https://github.com/YaLTeR/niri) with
  [Noctalia](https://github.com/noctalia-dev/noctalia) as the shell.
- **CLI** — [zsh](https://www.zsh.org), [Ghostty](https://github.com/ghostty-org/ghostty),
  [Yazi](https://github.com/sxyazi/yazi), [Neovim](https://github.com/neovim/neovim)
  (LazyVim base with a custom colorscheme).
- **Apps** — [Zen Browser](https://github.com/zen-browser/desktop),
  [Obsidian](https://obsidian.md), [Vesktop](https://github.com/Vencord/Vesktop),
  GIMP, LibreOffice, and more.
- **Services** — [Syncthing](https://syncthing.net) (syncs `Pictures` between the
  hosts, both ways), [EasyEffects](https://github.com/wwmm/easyeffects),
  [undershell](https://github.com/EternalSelf-2328/undershell) desktop widgets,
  and a local Minecraft server (currently badly configured).
- **Dev / tooling** — C++ toolchain (gcc/clang), [opencode](https://opencode.ai),
  and [git-hooks.nix](https://github.com/cachix/git-hooks.nix) pre-commit checks
  (nixfmt, deadnix, statix, check-toml, detect-private-keys, noctalia-scrub,
  ripsecrets).

> `modules/noctalia/config/noctalia/noctalia-config.toml` is the tracked baseline
> (wallpaper paths, layout, plugin settings); secret plugin keys live per-machine
> in `~/.local/state/noctalia/settings.toml`, not in the repo.

## Repository layout

- `modules/<feature>/` — one folder per app or concern, holding `system.nix`
  (NixOS), `home.nix` (home-manager) and/or `config/` (its dotfiles). The machine
  foundation lives in `modules/system/`; not-daily-driver pieces in `modules/optional/`.
- `hosts/<host>/` — per-host deltas (`desk`, `t480`); `hosts/_template/` scaffolds a new one.
- `configuration.nix` / `home.nix` — import the system / home side of every feature.

See [docs/structure.md](docs/structure.md) for the full tree and
[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for how it fits together.

## Using / adapting this config

### Prerequisites

- NixOS unstable, flakes enabled, and [direnv](https://direnv.net) + nix-direnv
  for the dev shell.

### Personal values to change

| What | Where | Note |
|---|---|---|
| Username / paths | [`local.nix`](local.nix) | edit this one file |
| Minecraft UUIDs / MOTD | [`modules/optional/minecraft/system.nix`](modules/optional/minecraft/system.nix) | your own game account |
| Timezone | [`modules/system/users.nix`](modules/system/users.nix) | `Europe/Berlin` |
| Boot / Plymouth | [`modules/system/boot.nix`](modules/system/boot.nix) | update to your CPU/GPU if needed |
| Noctalia | [`modules/noctalia/config/noctalia/noctalia-config.toml`](modules/noctalia/config/noctalia/noctalia-config.toml) | replace with your own |

> `local.nix` holds only your username and paths — no secrets. Noctalia's plugin
> keys are handled out-of-repo and Syncthing pairs at runtime (not in the repo); a
> secrets manager for future system-level secrets is planned — see
> [docs/NOTES.md](docs/NOTES.md) → "Secrets & keys (future plan)".

### Files you'll likely want to remove

- `hosts/desk/` and `hosts/t480/`

### Setting up a new machine

Follow the SSH tutor, then the disko tutor, in [docs/NOTES.md](docs/NOTES.md).
New hosts are copied from `hosts/_template/` and installed with
[`scripts/provision.sh`](scripts/provision.sh).

> **Status:** the new-machine flow is **untested**. `scripts/provision.sh` is a
> draft and the disko/`_template` install path has not been exercised end to end.
> Test in a VM before using it on real hardware.

### Syncthing setup

Syncthing is paired **at runtime**: its device IDs and folder config live in
`~/.config/syncthing/config.xml` (outside the repo), not in Nix. Start Syncthing
and pair each machine once in the UI (or copy that file between hosts). Only
`Pictures` is shared, both ways. The service starts at boot. Disk labels are used
instead of UUIDs too, so no disk identifiers live in the repo.

## Development / validation

- `.envrc` (`use flake`) + direnv loads the devShell, whose `shellHook` installs
  the git pre-commit hooks (nixfmt, deadnix, statix, check-toml,
  detect-private-keys, noctalia-scrub, ripsecrets).
  `nix develop` does the same manually; `nix develop -c pre-commit run -a` runs
  them all.
- `nix flake check` evaluates both hosts and builds the pre-commit check. It does
  **not** build the systems (kept fast on purpose).
- Format with `nix fmt` (treefmt: nixfmt + deadnix); config in
  [`treefmt.toml`](treefmt.toml).

More commands: [docs/COMMANDS.md](docs/COMMANDS.md).

## AI assistance & scope

Parts of this configuration were written with the help of an AI assistant
([opencode](https://opencode.ai)). It is a personal project tuned to specific
hardware and shared **as is** — no warranty, and you will likely need to adapt it
to your own setup.

## Credits

Full credits, third-party notices, and licenses live in
[`docs/CREDITS.md`](docs/CREDITS.md) — this config builds on
[Niri](https://github.com/YaLTeR/niri) and
[Noctalia](https://github.com/noctalia-dev/noctalia), bundles a few third-party
configs, and the artwork credits are listed there too.

## License

MIT — see [`LICENSE`](LICENSE). This covers the Nix configuration only; bundled
third-party configurations and assets keep their own licenses (see
[Credits](#credits)).
