#!/usr/bin/env bash
#
# kde-export - export only the KDE settings that changed in a live session.
#
# Run on the machine that has the session (vivobook), from the repo root, as
# descryx:
#
#   ./scripts/kde-export.sh save     # baseline, right after a switch
#   ... change settings in Plasma as lena ...
#   ./scripts/kde-export.sh diff     # unified diff in plasma-manager syntax
#
# Merge the added (`+`) lines into users/lena/plasma-desktop.nix, then drop
# machine-specific noise (activity UUIDs, screen/output IDs, Dolphin, Logitech).
# The diff comes from rc2nix, pinned to flake.lock, run over two snapshots of
# the files it reads. It reads only
# /home/lena/.config and /home/lena/.local/share, which is why it needs sudo.
set -euo pipefail

[ -f flake.lock ] || {
  echo "run from the repo root (flake.lock not found)" >&2
  exit 2
}

user=${KDE_EXPORT_USER:-lena}
home=/home/$user
state=${XDG_CACHE_HOME:-$HOME/.cache}/kde-export
rev=$(nix eval --impure --raw --expr \
  '(builtins.fromJSON (builtins.readFile ./flake.lock)).nodes."plasma-manager".locked.rev')
pkg="github:nix-community/plasma-manager/$rev"

# Mirrors rc2nix's KNOWN_CONFIG_FILES/KNOWN_DATA_FILES. Keeping the list local
# means a snapshot stays small instead of copying the whole ~/.config.
config_files=(
  kcminputrc kglobalshortcutsrc kactivitymanagerdrc ksplashrc kwin_rules_dialogrc
  kmixrc kwalletrc kgammarc krunnerrc klaunchrc plasmanotifyrc systemsettingsrc
  kscreenlockerrc kwinrulesrc khotkeysrc ksmserverrc kded5rc plasmarc kwinrc
  kdeglobals baloofilerc dolphinrc klipperrc plasma-localerc kxkbrc
  ffmpegthumbsrc kservicemenurc kiorc ktrashrc kuriikwsfilterrc plasmaparc
  spectaclerc katerc yakuakerc
)
data_files=(
  kate/anonymous.katesession
  dolphin/view_properties/global/.directory
)

snapshot() {
  local out=$1 f
  # The state dir must belong to the invoking user: nix run needs
  # ~/.cache/nix, and sudo would otherwise create ~/.cache as root.
  mkdir -p "$state"
  sudo rm -rf "$out"
  sudo install -d -m 0700 "$out/config" "$out/data"
  for f in "${config_files[@]}"; do
    if sudo test -f "$home/.config/$f"; then
      sudo cp -a "$home/.config/$f" "$out/config/$f"
    fi
  done
  for f in "${data_files[@]}"; do
    if sudo test -f "$home/.local/share/$f"; then
      sudo install -d "$out/data/$(dirname "$f")"
      sudo cp -a "$home/.local/share/$f" "$out/data/$f"
    fi
  done
  sudo chown -R "$(id -u):$(id -g)" "$state"
}

capture() {
  XDG_CONFIG_HOME=$1/config XDG_DATA_HOME=$1/data nix run "$pkg"
}

case ${1:-} in
save)
  snapshot "$state/base"
  echo "baseline: $state/base"
  ;;
diff)
  if [ ! -d "$state/base" ]; then
    echo "no baseline - run '$0 save' before changing settings" >&2
    exit 1
  fi
  snapshot "$state/live"
  capture "$state/base" >"$state/base.nix"
  capture "$state/live" >"$state/live.nix"
  echo "base: $state/base.nix"
  echo "live: $state/live.nix"
  diff -u "$state/base.nix" "$state/live.nix" || true
  ;;
*)
  echo "usage: $0 save|diff" >&2
  exit 2
  ;;
esac
