# Notes

Tutors and working notes for this repo. Day-to-day commands are in
[COMMANDS.md](COMMANDS.md).

## Filesystem labels (live hosts)

The live hosts (`desk`, `t480`) identify filesystems by label, not UUID, so no
disk IDs live in the repo. Conventions: btrfs root `nixos`, ESP `boot`, plus data
disks (`games`, `very-hard-drive`, `cachyos-drive`, `old-ssd`, `old-ssd-2`).
`hosts/<host>/hardware-configuration.nix` references `/dev/disk/by-label/<name>`.
New machines use disko `by-partlabel` instead (see the disko tutor below).

Check what a machine has:

```sh
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID
ls -l /dev/disk/by-label/
```

Set a label (metadata only, non-destructive):

```sh
sudo btrfs filesystem label /                  nixos       # root btrfs
sudo fatlabel /dev/disk/by-uuid/<ESP-UUID>     boot        # EFI (vfat); unmount /boot if busy
sudo ntfslabel /dev/disk/by-uuid/<UUID>        old-ssd-2   # unmount the NTFS volume first
```

Changing a mount's `device` takes effect at boot: apply with `nh os boot` and
reboot, not `nh os switch` (which tries to remount `/home` live and fails).

## Noctalia plugin keys

Entered once per machine in the Noctalia Settings UI and stored in
`~/.local/state/noctalia/settings.toml` (never the repo):

- `rylos/syncthing` api_key
- `zumik3-del/opencode-go-usage` api_key
- `Wallhaven` api_key

## New machine: SSH and git identity

1. Generate the key and load it:

   ```sh
   ssh-keygen -t ed25519 -C "85964170+descryx@users.noreply.github.com"
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_ed25519
   cat ~/.ssh/id_ed25519.pub
   ```

2. Add the public key to GitHub (Settings -> SSH and GPG keys -> New SSH key).
3. Test it: `ssh -T git@github.com`.
4. Set the noreply identity before any commit:

   ```sh
   git config --global user.name  "descryx"
   git config --global user.email "85964170+descryx@users.noreply.github.com"
   ```

   home-manager writes this too (`modules/apps/dev/home.nix`), so a bootstrapped
   machine already has it.

5. GitHub privacy settings (one-time, web): Settings -> Emails -> keep my email
   addresses private, and block command-line pushes that expose it.
6. Check no real email will be committed:

   ```sh
   git log --all --format='%ae' | sort -u \
     | grep -vE 'users\.noreply\.github\.com|noreply@github\.com'
   ```

   Anything other than the noreply address means do not push.

## Disko tutor (new machine / fresh NixOS install) NOT TESTED!

Goal: boot the installer, do the SSH steps above, then run one command and end up
with a working NixOS config. This is for brand-new machines only; nothing here
runs by itself.

disko turns manual partitioning into a Nix file. You describe disks, partitions,
filesystems and mountpoints in `hosts/<host>/disk-config.nix`, then disko wipes
the target disk and creates the layout.

Things to know:

- disko labels each GPT partition (e.g. `gpt-main-root`) and sets
  `fileSystems.<mountpoint>.device = "/dev/disk/by-partlabel/..."`, which is
  stable across reformats (unlike the by-uuid entries `nixos-generate-config`
  normally writes).
- Because disko defines `fileSystems` itself, `hardware-configuration.nix` must be
  generated with `--no-filesystems`, or NixOS reports conflicting definitions.
  `scripts/provision.sh` does this for you.
- Layout: 1G vfat ESP on `/boot`, the rest btrfs with subvolumes `@` (/),
  `@home`, `@nix`, `@log`, `@snapshots` (all `compress=zstd,noatime`).
- UEFI only (ESP/EF00, systemd-boot in `modules/system/boot.nix`).

> **Warning:** `disko-install` and `--mode destroy,format,mount` erase the target
> disk. Check the device with `lsblk` and use `/dev/disk/by-id/...`, not names
> like `/dev/nvme0n1`.

Flow:

0. Boot the NixOS ISO in UEFI mode, connect, do the SSH setup above, then:

   ```sh
   git clone git@github.com:descryx/nix-config.git /tmp/nix-config
   cd /tmp/nix-config
   ```

1. Find the disk (nothing is written yet):

   ```sh
   lsblk
   ls -l /dev/disk/by-id/
   ```

2. Create the host from the template, set the disk in `disk-config.nix` and the
   hostname in `default.nix`, then add it to `flake.nix` under
   `nixosConfigurations` (copy the `desk` or `t480` entry). You can do this on your
   current machine before travelling, then push.

   ```sh
   cp -r hosts/_template hosts/<new>
   $EDITOR hosts/<new>/disk-config.nix
   $EDITOR hosts/<new>/default.nix
   ```

3. Install (the only destructive step):

   ```sh
   sudo ./scripts/provision.sh <new> /dev/disk/by-id/<disk>
   ```

   It generates `hosts/<new>/hardware-configuration.nix` with `--no-filesystems`,
   makes you retype the device to confirm, and runs `disko-install` with
   `--write-efi-boot-entries`.

4. Reboot, pull the USB stick.
5. Save the generated hardware config. The ISO runs in RAM, so the `/tmp` clone is
   gone after reboot:

   ```sh
   git clone git@github.com:descryx/nix-config.git ~/nix-config
   cp /etc/nixos/hardware-configuration.nix ~/nix-config/hosts/<new>/
   git -C ~/nix-config add hosts/<new> flake.nix
   git -C ~/nix-config commit -m "add <new> host" && git -C ~/nix-config push
   ```

`--write-efi-boot-entries` matters because `modules/system/boot.nix` uses
systemd-boot with `efi.canTouchEfiVariables`, and disko-install does not write
NVRAM entries by default.

### Manual fallback

If the script breaks, run disko standalone:

```sh
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount ./hosts/<new>/disk-config.nix
nixos-generate-config --no-filesystems --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/<new>/
sudo nixos-install --flake .#<new>
reboot
```

### Status

`desk` and `t480` still declare `fileSystems` by label, which conflicts with
disko, so they are not migrated. Doing so needs a one-time regeneration with
`--no-filesystems`; leave it until you actually want to wipe them.
`scripts/provision.sh` and `hosts/_template/` are untested drafts, so read them
before running.

## Syncthing

Syncthing pairs at runtime: its device IDs and folder config live in
`~/.config/syncthing/config.xml`, outside the repo. `modules/services/syncthing/system.nix`
installs the service (starts at boot); pair each machine once in the UI, or copy
that file between hosts. Only `Pictures` is shared, both ways.

## Secrets & keys (plan)

`docs/things-to-remove.md` is the inventory. The goal is no plaintext secrets in
the repo. Noctalia's keys are already handled; a manager for system-level secrets
is still to be decided.

Current state (Noctalia): the tracked baseline is kept secret-free by
`scripts/noctalia-export.sh` plus the `ripsecrets` hook, and keys live per machine
in `settings.toml`. No agenix or sops needed for these.

Options, simplest to strongest:

1. Scrub-and-track: keep the file tracked with secret fields blank and paste the
   real values once per machine. No crypto. This is what we do for Noctalia.
2. Untrack + template: `.gitignore` the file, commit a `*.template`. Same manual
   paste, but no live versioning.
3. sops-nix: ciphertext in the repo, decrypted at activation to `/run/secrets/...`.
   Note sops has no TOML backend (YAML, JSON, ENV, INI only).
4. agenix: ciphertext in the repo, decrypted at activation to `/run/agenix/...`.

Why not a plain `secrets.nix` or a photo:

- `import ./secrets.nix` copies plaintext into `/nix/store` (world-readable) and
  into every generation, and breaks evaluation on a fresh clone.
- A photo is a bad backup (cloud sync, no integrity). Prefer age/gpg or a password
  manager.
- The current secrets are app-level, so there is no NixOS service to wire them
  into.

YubiKey, if we go that route:

- A hardware token (Yubico). Private keys are generated on the device and never
  leave it; signing and decrypting need a touch, sometimes a PIN.
- Holds FIDO2/WebAuthn passkeys, PIV certs (SSH via PKCS#11, `age-plugin-yubikey`),
  OpenPGP and OATH-TOTP. The YubiKey 5 series has everything; the cheaper Security
  Key series is FIDO2 only (no PIV/OpenPGP, so not enough for age/GPG).
- NixOS bits: `services.pcscd.enable`, `services.udev.packages` with
  `pkgs.yubikey-personalization`, `programs.gnupg.agent.enable`.

> Buy two. A YubiKey can be lost or broken and its keys cannot be exported.
> Register both as recipients. It is a root of trust, not a backup.

## Want to try

- Obsidian: see if basic settings (theme, vim mode, readable line length) can be
  declared.
- Sops: decide later; no YubiKey owned yet. Goal is no password to manage.
- Nvim: try [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim) against just
  keeping packages in systemPackages with a vanilla Lua config symlinked.
