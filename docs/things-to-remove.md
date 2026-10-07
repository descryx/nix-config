# things-to-remove

Tracking list of anything that must be kept out of this repo. Keep it updated
whenever a new secret or identifying value is noticed.

## Credentials / keys

- No secret values live in
  `modules/noctalia/config/noctalia/noctalia-config.toml`. The real plugin keys live
  per-machine in `~/.local/state/noctalia/settings.toml` (outside the repo) and are
  entered once in the Noctalia Settings UI.
- Never commit private SSH keys, tokens, passwords or API keys. `~/.ssh` stays
  outside the repo.
- `scripts/noctalia-scrub.sh` strips `api_key`/`password` lines from an exported
  config and reports (without deleting) other sensitive fields; the `ripsecrets`
  pre-commit hook is a catch-all scanner.

## Identifiers (not credentials, but identifying)

- **Kept out** — Syncthing pairs at runtime (`~/.config/syncthing/config.xml`), so
  no device IDs live in the repo.
- **Kept out** — filesystems are mounted by label (`by-label/nixos`, `boot`,
  `cachyos-drive`, `games`, `very-hard-drive`, `old-ssd`, `old-ssd-2`), so no disk
  UUIDs live in the repo.
- Minecraft player UUID + MOTD — the server is disabled (commented out in
  `hosts/*/default.nix`) and uses placeholder values.

## Personal / location

- Timezone `Europe/Berlin` (low risk).
- No static IPs, no precise location.

## Publishing

The public repo is a fresh `git init` (no history), so nothing from the old private
repo's history ships. Keep the new history clean: use the noreply email only (see
the SSH tutor in `docs/NOTES.md`).

## Future secret handling

- Noctalia plugin keys are handled **without** a manager: baseline scrubbed,
  `scripts/noctalia-scrub.sh` + the `ripsecrets` pre-commit hook, keys per-machine
  in `settings.toml`. See `docs/COMMANDS.md` -> "Noctalia config & secrets".
- agenix/sops is deferred until there is a **system-level** secret (or Noctalia's
  calendar / encrypted-clipboard credential files). Options and trade-offs are in
  `docs/NOTES.md` under "Secrets & keys (future plan)".
