# Notes

Tutors and working notes. Day-to-day commands are in [COMMANDS.md](COMMANDS.md).

## Filesystem labels (live hosts)

Filesystems are identified by label, not UUID, so no disk IDs live in the repo:
btrfs root `nixos`, ESP `boot`, plus data disks (`games`, `very-hard-drive`,
`cachyos-drive`, `old-ssd`, `old-ssd-2`). Check with `lsblk -o
NAME,SIZE,FSTYPE,LABEL,UUID`.

```sh
sudo btrfs filesystem label /               nixos       # root btrfs
sudo fatlabel /dev/disk/by-uuid/<ESP-UUID>  boot        # EFI; unmount /boot first
# NTFS: unmount the volume first; ntfslabel ships in ntfs3g (nix shell nixpkgs#ntfs3g)
sudo ntfslabel /dev/disk/by-uuid/<UUID>     old-ssd-2
```

A mount's `device` change takes effect at boot: `nh os boot` then reboot, not
`nh os switch` (it remounts `/home` live and fails).

## New machine: SSH and git identity

```sh
ssh-keygen -t ed25519 -C "85964170+descryx@users.noreply.github.com"
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub           # add to GitHub -> Settings -> SSH and GPG keys
ssh -T git@github.com
git config --global user.name "descryx"
git config --global user.email "85964170+descryx@users.noreply.github.com"
```

Before pushing, check no real email is in history: `git log --all --format='%ae'
| sort -u | grep -vE 'users\.noreply\.github\.com|noreply@github\.com'`. Anything
but the noreply address means do not push.

## Want to try

- Obsidian: declare basic settings (theme, vim mode, readable line length).
- Sops: decide later; no YubiKey owned yet. Goal is no password to manage.
- Nvim: try [nixCats-nvim](https://github.com/BirdeeHub/nixCats-nvim) against just
  keeping packages in systemPackages with a vanilla Lua config symlinked.
