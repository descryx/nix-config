# nix-config (NixOS + home-manager flake, hosts: desk, t480, vivobook)

## Hard rules
- Show a diff and explain it before applying changes. Never rebuild/switch,
  commit, or push without asking.
- Never run `nix flake update` or change `flake.lock` on t480 or vivobook.
  Updates happen on desk only.
- Never put a secret value in the repo. Don't open or print files that look
  secret (keys, tokens, .env). If you find one, tell me the file path and kind
  only, never the value. See docs/ARCHITECTURE.md -> "Secrets".
- When a secret is needed, suggest options for keeping it out of the repo
  (e.g. sops-nix or agenix) and explain the trade-offs. Don't pick one for me.
- The tracked Noctalia baseline must stay secret-free. Regenerate it only with
  scripts/noctalia-export.sh, never by redirecting a raw export into the file.
  See docs/COMMANDS.md -> "Noctalia config & secrets".
- Never invent option names. Verify against the NixOS / home-manager docs or
  source for the version this flake pins, and name that version. If you can't
  verify, say "unverified".
- If unsure, ask. Don't guess.

## Layout and conventions
- Full rationale: docs/ARCHITECTURE.md. Verify against the real tree, not from
  memory.
- modules/ is grouped by category, one folder per feature:
  core/ (machine foundation, flat files), desktop/ (session and look),
  apps/ (one app per folder), services/ (daemons, device glue),
  bundles/ (package lists, defaults), optional/ (off by default).
- A feature lives in one folder, modules/<category>/<feature>/, holding any of
  system.nix, home.nix, config/. Never split a feature across folders.
- Home-manager roots live in users/<name>/home.nix; users/<name>/system.nix
  declares an extra account. flake.nix's homeUsers map decides which users a
  host gets. Never put a user's home.nix under modules/: lib/modules.nix
  auto-imports every home.nix there and would leak it into the other user.
- lib/mk-system.nix builds a host; lib/user-options.nix holds per-user options.
- Dotfiles: the owner uses my.dotfiles.live = true (out-of-store symlink); a
  second user uses false (store copy). KDE rc files are not symlinked at all;
  KDE rewrites them atomically. Use plasma-manager in users/lena/*.nix; live
  tweaks are exported with scripts/kde-export.sh, not hand-merged rc2nix dumps.
- No disko. New hosts are installed manually with label-based fileSystems.
- Vivobook uses `nixpkgs-stable` (26.05) + `home-manager-stable`; desk/t480 stay
  unstable. Vivobook needs `linuxPackages_latest` (7.3) for the MT7902 Wi-Fi, and
  keeps 5 generations. `descryx` is hidden from SDDM there; lena is the only
  visible user. See docs/FAMILY.md.
- KDE: the SDDM theme is patched to preselect index 0 (niri/descryx on the
  owner's machines, plasma/lena on the laptop). The owner's GTK dconf values are
  pinned in modules/desktop/appearance/home.nix; lena uses Thunar, Dolphin is
  excluded. lena only exists on the Vivobook.
- Togglable features are declared in configuration.nix with mkEnableOption and
  their config is wrapped in lib.mkIf.
  The defaults sit next to the declarations in configuration.nix. Hosts set deltas. home.nix
  reads the switch via osConfig. Declare each option once.
- Use Nix (home-manager module) when the app has a good one. Large or often
  hand-edited configs go in config/ as out-of-store symlinked dotfiles. State
  which and why.
- New files must be git added before a flake build can see them. Remind me.
- Rebuild with nh, not nixos-rebuild. Use `nh os boot` (not switch) when
  changing fileSystems.
- option name = camelCase of the folder name

## Checks (run before saying a change is done)
- nix fmt
- nix flake check
- ./scripts/check-systems.sh (catches missing paths and bad derivations that
  flake check misses)
- Report what was and was not actually tested. A switch defaulting to false can
  make a program silently disappear, so confirm each host still enables what it
  had (nix store diff-closures against the previous build).

## Docs
- Update docs/ARCHITECTURE.md when structure or conventions change. Update
  README.md only for user-facing changes. Don't leave docs describing old
  behaviour.
- When I say "update the docs" (fully), audit every doc against the current
  repo: read the real tree and files plus each doc, fix anything that no longer
  matches (paths, commands, options, links), then report what changed and what
  you verified.
- Docs prose: use "-", not an em dash.
- Commit messages: see docs/COMMANDS.md.

## Explaining
- Explain module changes from the core up: what the option does, how the module
  system merges it, what ends up on the system.
- Label suggestions as common practice / good practice / bad practice, and say
  why. If something here is outdated or there's a better established way, say so
  and let me decide.
