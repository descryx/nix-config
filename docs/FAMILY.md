# Vivobook runbook (lena)

This is the maintenance runbook for the ASUS Vivobook 16 M1605YA. Architecture is
in [ARCHITECTURE.md](ARCHITECTURE.md); everyday commands are in
[COMMANDS.md](COMMANDS.md).

## Machine and users

- NixOS 26.05 stable, `linuxPackages_latest` (7.3) for the MediaTek MT7902
  Wi-Fi/Bluetooth, `hardware.enableRedistributableFirmware = true`.
- KDE Plasma 6, only Wayland session, no niri/umbriel/noctalia.
- `lena`: daily user, KDE, non-wheel, home-manager profile.
- `descryx`: maintenance account, wheel, SSH key, zsh, no home-manager profile.
  Hidden from SDDM on this host with `services.displayManager.hiddenUsers`, so
  lena is the only visible user and the theme's index-0 default.
- Generations: keep 5 system generations (`configurationLimit` and
  `nh clean --keep 5`). No btrfs snapshot service.
- Printer: Canon PIXMA TS5050, USB only.

## Before installing

1. Back up everything from Windows to the exFAT USB. Mark OneDrive folders
   "Always keep on this device" before copying; BitLocker volumes must be
   decrypted from Windows first. Shut Windows down fully, not Fast Startup.
2. Copy that USB to desk before reusing it as the installer. Desk has space on
   `/home`, `/mnt/games` and `/mnt/cachyos-drive`. The same USB can then be
   written with the NixOS 26.05 ISO. Ventoy is the alternative if you need the
   ISO and data on one USB.
3. The 26.05 installer ISO uses the 6.18 kernel and has no MT7902 driver. Use
   Ethernet, phone USB tethering or a USB Wi-Fi dongle during install. The
   installed host gets 7.3 and the firmware.
4. Confirm the repo has `hosts/vivobook` and `nixosConfigurations.vivobook`, and
   that the stable build/VM test has passed on desk.

## OpenCode and LearnHarness data from Windows

OpenCode on Windows uses the XDG-style path, not `%LOCALAPPDATA%`:

```text
C:\Users\<user>\.local\share\opencode\
  opencode.db
  opencode.db-wal
  opencode.db-shm
  auth.json        <- secret; prefer re-login
  snapshot\
  tool-output\
  shell\
  repos\
```

`opencode debug paths` confirms the exact path. Quit OpenCode before copying the
database. The portable option is `opencode session export <id>` on Windows and
`opencode session import` on NixOS.

On NixOS the data belongs in `~/.local/share/opencode`, the config in
`~/.config/opencode`, and optional state in `~/.local/state/opencode`. After
copying, `chown -R lena:users` if the files land under lena's account. Do not put
`auth.json` on an unencrypted USB unless you accept the risk; sign in again on
the target.

Version note: 26.05 stable still ships `opencode-desktop` 1.15.10, which cannot
read a 2.x database. `users/lena/home.nix` therefore takes 2.2.6 (the version
desk runs) from the unstable input. It is the only unstable package on this
host; do not "fix" it back to the stable one without exporting her sessions
first.

LearnHarness is an Electron AppImage. Launch it once after install to see which
directory it creates (`~/.config/learnharness` or `~/.config/LearnHarness`), then
replace that directory with the Windows data folder. Documents go to
`/home/lena/Documents`, `Pictures`, etc., followed by
`sudo chown -R lena:users /home/lena/...`.

## Install

Work from the NixOS 26.05 installer with a network connection.

1. Partition the target NVMe. Confirm the device first (`lsblk -o
   NAME,SIZE,MODEL,SERIAL,FSTYPE`); the Windows disk is the one with the
   Microsoft/EFI partitions. Then, with the repo's label-based layout (no LUKS,
   no swap):

   ```sh
   DISK=/dev/nvme0n1   # verify before every destructive command below
   sgdisk --zap-all "$DISK"
   sgdisk -n1:0:+1G -t1:ef00 -c1:boot  "$DISK"
   sgdisk -n2:0:0   -t2:8300 -c2:nixos "$DISK"
   mkfs.fat -F32 -n boot "${DISK}p1"
   mkfs.btrfs -L nixos "${DISK}p2"
   mount "${DISK}p2" /mnt
   btrfs subvolume create /mnt/@{,@home,@nix,@log}
   umount /mnt
   ```

   The labels are case-sensitive because `hardware-configuration.nix` uses
   `/dev/disk/by-label/boot` and `/dev/disk/by-label/nixos`. Check with
   `sudo blkid`; `mkfs.fat` keeps `boot` lowercase, but if it comes out as
   `BOOT` fix it with `sudo fatlabel "${DISK}p1" boot`.

2. Mount the subvolumes under `/mnt` in the order the configuration expects:

   ```sh
   mount -o subvol=@ "${DISK}p2" /mnt
   mkdir -p /mnt/{home,nix,var/log,boot}
   mount -o subvol=@home "${DISK}p2" /mnt/home
   mount -o subvol=@nix  "${DISK}p2" /mnt/nix
   mount -o subvol=@log  "${DISK}p2" /mnt/var/log
   mount "${DISK}p1" /mnt/boot
   lsblk -f   # expect nixos on /mnt/{,home,nix,var/log} and boot on /mnt/boot
   ```
3. `hosts/vivobook/hardware-configuration.nix` is already the real file for
   this machine and is what the installed system boots with. Generating a
   fresh one is optional: `nixos-generate-config --root /mnt --no-filesystems
   --show-hardware-config` prints it. Diff it against the committed file and
   only adopt module lists that are missing; keep the label-based
   `fileSystems` by hand.
4. Clone this repo on the live system, `git add` the generated hardware file
   (the flake cannot see untracked files), and run:

   ```sh
   nixos-install --flake /path/to/repo#vivobook --root /mnt
   ```

5. Reboot. Set passwords with `sudo passwd lena` and `sudo passwd descryx`.
   `descryx` is hidden from SDDM but can log in over SSH or a TTY; its password
   is for `sudo`.
6. SSH from desk with the committed public key. Verify Wi-Fi on 5 GHz, Bluetooth,
   suspend/resume, internal microphone, touchpad and the webcam.

## Printer and scanner

The printing module enables CUPS, gutenprint and SANE. Plug the TS5050 in over
USB, then:

```sh
lpinfo -v
sudo lpadmin -p Canon_TS5050 -E -v '<usb URI from lpinfo -v>' \
  -m 'gutenprint.5.3://bjc-PIXMA-TS5050/expert'
sudo lpadmin -d Canon_TS5050
lpstat -p -d
scanimage -L
```

Print a test page and scan once with Skanpage. Do not add Avahi or a network
queue; this printer is USB-only. Gutenprint marks the TS5050 driver EXPERIMENTAL;
if output is unacceptable, `cnijfilter2` has only the generic TS5000 series PPD.

## Apps and Google Calendar

lena's profile ships Parley (vocabulary trainer), Drawy (infinite whiteboard) and
Merkuro (calendar and contacts). Drawy is not in nixpkgs, so it lives in
`modules/apps/` and reaches the hosts through the flake overlay.

The wallpaper is Plasma's built-in slideshow plugin. Nix sets the plugin and a
three-day interval; pick the images once in Desktop Settings -> Wallpaper ->
Slideshow. The image list lives in the Plasma applet config, not in this repo, so
it survives rebuilds. Plasma's UI only offers up to 24 hours in its interval
field; do not change it there, or run `nh os switch` afterwards to restore the
three-day value.

Google Calendar goes through Akonadi, not Online Accounts. KAccounts would need
`signon-ui`, which is not packaged, while the Akonadi Google resource does its
own LibKGAPI OAuth. `my.kdePim.enable` installs akonadi, kdepim-runtime (the
Google resource) and kdepim-addons system-wide; the last one matters because the
Digital Clock loads calendar plugins from `QT_PLUGIN_PATH`, not from lena's
profile.

1. Open Merkuro -> Calendar -> Add calendar -> "Google Calendar and Tasks".
2. Sign in through the browser; the tokens are stored in KWallet.
3. Right-click the Digital Clock -> Configure -> Calendar -> enable the PIM
   Events plugin and select the Google calendar.

That selection is live as well. If Google rejects the OAuth client, fall back to
the calendar's secret iCal address with the iCal resource: read-only and no
OAuth, but it works without the account.

## Spickzettel

`users/lena/cheatsheet.nix` generates a German, print-ready keybinding sheet at
`~/.local/share/spickzettel/spickzettel.pdf` and binds it to `Meta+H` through
plasma-manager. WeasyPrint turns the HTML built from the Nix lists into an A4
PDF at build time; Okular opens it in its own window (`--unique`, so repeating
Meta+H reuses it). `Strg+P` prints from Okular. Edit the lists in that file,
not the installed PDF. Plasma applies the hotkey on the next login, not during
the rebuild. `Meta+F1` was not used because lena's captured KWin config already
has it on "Switch to Desktop 1". The sheet calls the Windows key "Super";
KDE's own shortcut syntax only knows it as `Meta`.

## Updates

Only desk touches `flake.lock`:

```sh
cd /home/descryx/nix-config
nix flake update nixpkgs-stable home-manager-stable
nix flake check
./scripts/check-systems.sh
# test the stable VM, then commit and push
```

On Vivobook:

```sh
cd /home/descryx/nix-config
git pull
sudo nh os switch
```

Never run `nix flake update` or edit `flake.lock` on Vivobook or t480. To avoid a
long laptop build, build the toplevel on desk and `nix copy --to
ssh-ng://descryx@vivobook <path>` first. Roll back from the systemd-boot menu or
with `nh os rollback`.

## Caveats

- MT7902 Wi-Fi and Bluetooth share one antenna; 2.4 GHz Wi-Fi is unstable with
  Bluetooth on. Use a 5 GHz SSID. The printer is USB, so it does not depend on
  the 2.4 GHz radio.
- The look is the Fluent Round Dark global theme from the GPL upstream repo.
  Its look-and-feel defaults are patched to use the Win11 color scheme and
  icons, Breeze Plasma style, Bibata cursors and the Kuro OLED splash. The
  Windows wallpaper, Kvantum widget style and Win10 cursor are not used; the
  wallpaper is the Plasma slideshow.
- The installer ISO has no MT7902 driver; the installed system does.
- No snapshots: keep an external backup for documents. The system generations
  are for rollback, not for data. The disk is deliberately not LUKS-encrypted,
  like the other hosts; the laptop is the one that leaves the house, so the
  backup is what protects the data.
