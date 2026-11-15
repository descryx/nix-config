#!/usr/bin/env bash
#
# notify-lena - send a desktop notification to lena's Plasma session.
#
# Run on the Vivobook as descryx (or over SSH with -t). The sudo prompt is
# only there to enter her session bus; /run/user/<uid> is 0700.
#
#   ./scripts/notify-lena.sh "Kaffeepause" "Zeit für eine Pause."
#
# busctl is already in the system profile, so this needs no extra package.
set -euo pipefail

title=${1:?usage: $0 "title" ["body"]}
body=${2:-}
uid=$(id -u lena)

exec sudo -u lena env \
  XDG_RUNTIME_DIR=/run/user/"$uid" \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$uid"/bus \
  /run/current-system/sw/bin/busctl --user call \
  org.freedesktop.Notifications /org/freedesktop/Notifications \
  org.freedesktop.Notifications Notify susssasa{sv}i \
  "Mama" 0 "dialog-information" "$title" "$body" 0 0 0
