## Those are personal notes and useful info overall.

## extra notes:
Disko layout lives per host at `hosts/<host>/disk-config.nix` (copy from
`hosts/_template/`). See the "Disko tutor" below before touching any disk.

---

## Filesystem labels (live hosts)

The live hosts (`desk`, `t480`) identify filesystems by **label**, not UUID, so no
disk IDs live in the repo. Conventions: btrfs root → `nixos`, ESP → `boot`, plus
data disks (`games`, `very-hard-drive`, `cachyos-drive`, `old-ssd`, `old-ssd-2`).
`hosts/<host>/hardware-configuration.nix` references `/dev/disk/by-label/<name>`.
(New machines use disko `by-partlabel` instead — see the tutor below.)

Check what a machine has:

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID
ls -l /dev/disk/by-label/
```

Set a label (metadata only — non-destructive, no data touched):

```sh
sudo btrfs filesystem label /                  nixos       # root btrfs
sudo fatlabel /dev/disk/by-uuid/<ESP-UUID>     boot        # EFI (vfat); unmount /boot if busy
sudo ntfslabel /dev/disk/by-uuid/<UUID>        old-ssd-2   # unmount the NTFS volume first
```

Changing a mount's `device` takes effect at boot: apply with `nh os boot` +
reboot, **not** `nh os switch` (which tries to remount `/home` live and fails with
`failed to restart home.mount`).

---
## api_keys to fill out (Noctalia Settings UI -> ~/.local/state/noctalia/settings.toml, never the repo)

- rylos/syncthing api_key > Noctalia plugin
- zumik3-del/opencode-go-usage api_key > Noctalia plugin
- Wallhaven api_key > Noctalia plugin

---
## New machine — SSH key + email-privacy safe git setup

1. Generate the key (on the new machine)
ssh-keygen -t ed25519 -C "85964170+descryx@users.noreply.github.com"

2. Start agent + add key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

3. Copy public key
cat ~/.ssh/id_ed25519.pub

4. Add to GitHub — Settings → SSH and GPG keys → New SSH key → Authentication.

5. Test auth
ssh -T git@github.com

6. Lock in the noreply identity BEFORE any commit
- git config --global user.name  "descryx"
- git config --global user.email "85964170+descryx@users.noreply.github.com"
- git config --global --get user.email   # must print the noreply address
(Skip the manual config if home-manager already writes it via modules/dev/home.nix — it does, so this is just the fallback before bootstrap.)

7. GitHub privacy settings (one-time, web UI) — Settings → Emails:
- Enable Keep my email addresses private.
- Enable Block command line pushes that expose my email.

8. Safety check — confirm no real email will be exposed
# what's actually configured?
git config user.email

# every author email across all commits/branches/tags
git log --all --format='%ae' | sort -u

# flag anything that is NOT an allowed noreply address (non-empty = problem)
git log --all --format='%ae' | sort -u \
  | grep -vE 'users\.noreply\.github\.com|noreply@github\.com'

9. Clone
git clone git@github.com:descryx/nix-config.git
10. Repeat the check before every push (or wire it as a pre-push hook):
git log origin/main..HEAD --format='%ae' | sort -u   # only new commits
If step 8/10 prints anything other than the noreply address, do not push — fix with git commit --amend --author="descryx <85964170+descryx@users.noreply.github.com>" (for the tip) or rewrite history for older commits.

> Publishing note: the public repo is a fresh `git init` (no history), so the
> email/API-key leaks from the old private repo never ship. Keep the new history
> clean with the checks above.

---
## Disko tutor (new machine / fresh NixOS install)

> Goal: boot the installer, do the SSH init, then run one command and end up
> with a fully working NixOS config. This is for BRAND-NEW machines. Nothing
> here runs by itself — the install only happens when you run it.

### What disko is and how it works
disko turns manual partitioning into a Nix file. You describe disks, partitions,
filesystems and mountpoints in `hosts/<host>/disk-config.nix`, then disko wipes
the target disk and creates the layout.

Important details:
- disko labels each GPT partition (e.g. `gpt-main-root`) and sets
  `fileSystems.<mountpoint>.device = "/dev/disk/by-partlabel/..."`.
  `by-partlabel` is stable across reformats, unlike the `/dev/disk/by-uuid/...`
  entries `nixos-generate-config` normally writes into hardware-configuration.nix.
- Because disko defines `fileSystems` itself, `hardware-configuration.nix` must
  be generated with `--no-filesystems`, otherwise NixOS reports conflicting
  `fileSystems` definitions. `scripts/provision.sh` does this for you.
- The layout: 1G vfat ESP mounted `/boot`, remainder btrfs with subvolumes
  `@` (/), `@home`, `@nix`, `@log`, `@snapshots` (all `compress=zstd,noatime`).
- UEFI only (ESP/EF00, systemd-boot in `modules/system/boot.nix`). No BIOS/MBR here.

### WARNING
`disko-install` and `--mode destroy,format,mount` ERASE the target disk. Always
check the device with `lsblk`, and prefer `/dev/disk/by-id/...` over names like
`/dev/nvme0n1` so you can never hit the wrong disk.

### Recommended flow (what "ssh init then disko" actually means)

0. Boot the NixOS ISO in **UEFI mode**, connect network, set up the SSH key
   (tutor above), then clone the repo:
```
git clone git@github.com:descryx/nix-config.git /tmp/nix-config
cd /tmp/nix-config
```
1. Find the disk (just look, nothing is written yet):
```
lsblk
ls -l /dev/disk/by-id/
```
2. Create the host from the template:
```
cp -r hosts/_template hosts/<new>
$EDITOR hosts/<new>/disk-config.nix   # set `device` to the by-id path
$EDITOR hosts/<new>/default.nix       # set networking.hostName = "<new>"
```
   Then add `<new>` to `flake.nix` under `nixosConfigurations` (copy the `desk`
   or `t480` entry and change the name).
   Tip: you can do step 2 on your current machine before travelling, then just
   `git push` — the new machine only needs steps 0, 3, 4, 5.
3. Install (this is the ONLY destructive command):
```
sudo ./scripts/provision.sh <new> /dev/disk/by-id/<disk>
```
   What it does:
   - generates `hosts/<new>/hardware-configuration.nix` with `--no-filesystems`
   - prints the disk and makes you retype the device to confirm
   - runs `disko-install` with `--write-efi-boot-entries`
4. Reboot and remove the USB stick. The machine should come up on the new config.
5. Save the generated hardware config to the repo. The live ISO runs in RAM, so
   the `/tmp` clone is gone after reboot. After logging in:
```
cd ~/nix-config   # or: git clone git@github.com:descryx/nix-config.git
cp /etc/nixos/hardware-configuration.nix hosts/<new>/hardware-configuration.nix
git add hosts/<new> flake.nix && git commit -m "add <new> host" && git push
```

### Why `--write-efi-boot-entries`
`modules/system/boot.nix` uses systemd-boot with `efi.canTouchEfiVariables`.
disko-install does not write NVRAM boot entries by default, so without this flag
the machine may not add its own boot entry.

### Manual fallback (if the script breaks)
disko standalone, no flake wiring needed:
```
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./hosts/<new>/disk-config.nix
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/<new>/
sudo nixos-install --flake .#<new>
reboot
```

### Reinstalling desk/t480 with disko [NOT DONE / DEFERRED]
The disko wiring now exists, but `desk`/`t480` still declare `fileSystems` by
label in their `hardware-configuration.nix`, which conflicts with disko. Adopting
disko for them needs a one-time regeneration with `--no-filesystems`. Leave this
alone until you actually want to wipe those machines.

### Script status
`scripts/provision.sh` is NOT practically tested yet — treat it as a draft and
read it before running. `hosts/_template/` is likewise untested.

---
## do not leak:
Single source of truth: `docs/things-to-remove.md`.
(older list kept here for reference)
- wallheaven api
- static ip of any kind
- any kind of precise location ("timezone europe/berlin" does not count)
- any kind of api`s , tokens, ssh keys, passwords, etc.

---

## Syncthing

Syncthing pairs at **runtime**: its device IDs and folder config live in
`~/.config/syncthing/config.xml`, outside the repo. `modules/syncthing/system.nix`
installs the service (starts at boot); pair each machine once
in the UI (or copy the file between hosts). Only `Pictures` is shared, both ways.

---

## Common commands

//

---

## Secrets & keys (future plan)

`docs/things-to-remove.md` holds the current inventory. Goal: the repo contains
no plaintext secrets. Noctalia's app keys are already handled (below); a manager
for future system-level secrets is still to be decided.

### Current state (Noctalia) — resolved without a manager
Noctalia v5 layers config: the tracked baseline
(`modules/noctalia/config/noctalia/noctalia-config.toml`) is secret-free, while plugin
API keys live in the per-machine `~/.local/state/noctalia/settings.toml`
(outside the repo) and are entered once per machine in the Settings UI.
`scripts/noctalia-scrub.sh` (run after `noctalia config export merged`) plus the
`ripsecrets` pre-commit hook keep the baseline clean. **No agenix/sops needed for
these.** agenix is reserved for future system-level secrets, or Noctalia's
calendar / encrypted-clipboard credential files.

### Options, simplest -> strongest
1. **Scrub-and-track**: keep `noctalia-config.toml` tracked but with the secret
   fields blank; keep the real values in a password manager / encrypted note and
   paste them once per new machine. No crypto. (Essentially what we do for
   Noctalia — see "Current state" above.)
2. **Untrack + template**: `.gitignore` the file, commit a `*.template`. Same
   manual paste; you lose live versioning of the Noctalia config.
3. **sops-nix** (SOPS + age): ciphertext in the repo, decrypted at activation to
   `/run/secrets/...`. Per-key recipients, so a secret can go to some hosts/users.
4. **agenix**: ciphertext in the repo, decrypted at activation to `/run/agenix/...`.
   age recipients are typically each host's SSH host key plus your user key.

### Why not a plain `secrets.nix` + a photo
- If a module does `import ./secrets.nix` and a value lands in a store path, the
  plaintext is copied to `/nix/store` (world-readable) and kept in every
  generation. That is worse than the app-owned gitignored file.
- `import ./secrets.nix` also breaks evaluation on a fresh clone (file absent).
- A photo is a bad backup: cloud/photo sync, no integrity, OCR errors. Prefer an
  encrypted backup (age/gpg) or a password manager.
- The current secrets are app-level (Noctalia plugins write their own config at
  runtime), so there is no NixOS service to wire them into.

### YubiKey (what it is / how it works)
- A small USB-A/USB-C/NFC hardware security token (Yubico). Private keys are
  generated on the device and never leave it (non-exportable); the host sends a
  challenge and you touch the key (PIN for some functions) to sign/decrypt.
- Holds: FIDO2/WebAuthn passkeys; PIV smart-card certs (SSH via PKCS#11,
  `age-plugin-yubikey`); OpenPGP (GPG, SSH via gpg-agent); OATH-TOTP; Yubico OTP /
  static password. Features differ by model.
- Models: YubiKey 5 series (full features, USB-A/C/NFC, ~$50-70) vs the cheaper
  Security Key series (FIDO2 only — no PIV/OpenPGP, so not enough for age/GPG).
- NixOS bits: `services.pcscd.enable`, `services.udev.packages` with
  `pkgs.yubikey-personalization`, `programs.gnupg.agent.enable`.
- `age-plugin-yubikey` keeps an age identity in a PIV slot; the public key is the
  recipient and decrypting needs the key + PIN/touch. (Verify the sops/agenix
  wiring when we actually set it up.)

> WARNING: **buy two.** A YubiKey can be lost or broken and its keys cannot be
> exported. Register both keys as recipients so one is a spare. It is a root of
> trust, not a backup of the secrets themselves.

---

## Want to try out / integrate, and overall plans for future.

- Obsidian
see if you can declare basic settings like theme, vim mode, apearance settings like readable line length.

- Sops/etc.
See "Secrets & keys (future plan)" above for the current thinking. No YubiKey
owned yet; decide later. Goal is no password to manage like a real password.

- Nvim
i heard about a tool called nixCats:
`https://github.com/BirdeeHub/nixCats-nvim`
see if its more convenient than just keeping the required packages inside systempackages and a vanilla lua nvim config symlinked. 
