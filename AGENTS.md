# nix-config (NixOS + home-manager, flake-based)

## Context
- Flake-based NixOS config with home-manager, multiple hosts: `desk` (desktop) and a ThinkPad T480.
- Rebuilds go through `nh` (`nh os switch`), not raw `nixos-rebuild`.
- `README.md` and `docs/structure.md` sketch the folder structure. `structure.md`
  may lag; verify against the real tree before relying on it or editing it.
- `docs/NOTES.md` holds things I want to try and my personal preferences. Read it at
  the start of a task and check for anything relevant. `docs/COMMANDS.md` is the
  command cheat-sheet.
- `git-hooks.nix` wires the pre-commit checks (nixfmt, deadnix, statix,
  `noctalia-scrub`, `ripsecrets`) into `nix flake check` and a devShell; `.envrc`
  loads that devShell via direnv.
- Noctalia plugin API keys live per-machine in
  `~/.local/state/noctalia/settings.toml` (outside the repo). The tracked baseline
  must stay secret-free; `scripts/noctalia-scrub.sh` + the hooks enforce that. See
  `docs/COMMANDS.md` -> "Noctalia config & secrets".

## Layout & conventions
- The repo is feature-first: one folder per app/concern under `modules/<feature>/`,
  holding any of `system.nix` (NixOS, imported by `configuration.nix`), `home.nix`
  (home-manager, imported by `home.nix`) and `config/` (the feature's dotfiles).
  The machine foundation (boot, networking, users, nix settings, `nh`, power,
  audio, tools) lives together in `modules/system/`. Host-specific deltas live in
  `hosts/<host>/`, including the desk-only OBS override.
- Not-daily-driver pieces live under `modules/optional/` and are imported by the
  host that wants them.
- User config is split between declarative Nix (each feature's `home.nix`) and
  symlinked dotfiles (each feature's `config/`, via out-of-store symlinks, for live
  editing). Rule of thumb: if the app has a good home-manager module, use Nix;
  huge or frequently hand-edited configs go in the feature's `config/`. Note which
  and why when adding one.
- Custom derivations live next to the feature that uses them (e.g.
  `modules/niri/niri-zoom.nix`); non-code assets likewise (e.g.
  `modules/optional/ollama/assets/`).
- New apps: create `modules/<name>/` with the relevant `system.nix`/`home.nix` +
  `config/`, then add it to the matching import list in `configuration.nix` /
  `home.nix` (or a host's `default.nix` for `optional/` items).

## Documentation
- Any change to code/config must come with the matching doc update in the same task
  (and the same commit): `README.md`, `docs/ARCHITECTURE.md`, `docs/COMMANDS.md`,
  `docs/structure.md`, `docs/NOTES.md`, `docs/CREDITS.md`,
  `docs/things-to-remove.md`, and this file — whichever the change touches. Never
  leave docs describing old behaviour.
- When I say to "update the docs" (fully), audit every doc against the current
  repo: read the real tree and files plus each doc, compare, and fix anything that
  no longer matches (paths, filenames, commands, options, structure, links). Then
  report what changed and what you verified.

## Workflow rules
- Show me a diff and explain it before applying any change. Never rebuild/switch,
  commit, or push without asking.
- Never run `nix flake update` (or change `flake.lock`) on the laptop. Updates only
  happen on desk, then get pushed and pulled.
- New files must be `git add`ed before a flake build can see them. Remind me if relevant.
- Commit messages follow `docs/COMMANDS.md` → "Commit messages".
- Validate with a build or `nix flake check` where possible, and tell me what was and
  wasn't actually tested. `nix flake check` evaluates both hosts and builds the
  pre-commit check (but not the systems).

## Teaching and accuracy
- Explain Nix module changes from the core up: what the option does, how the module system
  merges it, and what ends up on the system (store path, symlink, systemd unit, etc.).
- Label every suggestion as common practice / good practice / bad practice.
  Say which one and why.
- Never invent option names. Check the current NixOS / home-manager option docs or source
  for the version this flake pins, and name that version. If you can't verify, mark it
  "unverified".
- If something here is odd, outdated, or has a better established way, say so,
  explain the trade-offs, and let me decide whether it's worth integrating.

## Secrets
- Goal: this repo must be safe if made public. No secrets in it should remain.
- Don't open (open only if necesarry or asked for) or print plain files that look secret (keys, tokens, `.env`, password files)
  unless I ask.
- If you notice a secret or anything private (tokens, passwords, API keys, private hostnames/IPs,
  emails, SSH keys, Wi-Fi credentials), add it to `docs/things-to-remove.md` with the **file path
  and kind only, never the value**, and tell me. If a secret has already been committed,
  mention that git history keeps it and it would need rotating, not just deleting.
- When a secret is needed, suggest options for keeping it out of the repo
  (e.g. sops-nix or agenix) and explain the trade-offs. Don't pick one for me.
- Current inventory: `docs/things-to-remove.md`. Current thinking on secret tooling
  (incl. YubiKey): `docs/NOTES.md` -> "Secrets & keys (future plan)".
