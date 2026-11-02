#!/usr/bin/env bash
# Obsidian scratchpad for niri.
#
# Bound to Mod+Y. Behaves like a Hyprland/i3 scratchpad:
#   - if Obsidian is not running, launch it on the vault directory below
#     (the window-rule in window-rules.kdl makes it float, centered);
#   - otherwise toggle it: slide it to the edge + fade it out to hide, or
#     bring it back to the workspace you are looking at to reveal it.
#
# niri clamps floating windows so they always keep a sliver on screen, so a
# pure "off-screen" hide is impossible. Instead we slide it to the edge AND
# drop its opacity to 20% via toggle-window-rule-opacity (the window-rule sets
# `opacity 0.2`). It is never closed here - quit it yourself with Mod+W.
set -euo pipefail

# The vault directory to open. Set this to your vault's absolute path.
# (Obsidian 1.14 opens a folder passed as a positional argument.)
VAULT_DIR="$HOME/vaults/obsidian"

# Obsidian's Wayland app-id (from the desktop file StartupWMClass). Matched
# case-insensitively so it also covers the Xwayland WM_CLASS variant.
# Confirm the exact value with: niri msg -j windows
APP_ID_RE="obsidian"

# Session state marking Obsidian as currently hidden.
STATE="${XDG_RUNTIME_DIR:-/tmp}/niri-obsidian-scratchpad"

# Id of the Obsidian window, if any.
find_win() {
    niri msg -j windows \
        | jq -r --arg app "$APP_ID_RE" \
            '[.[] | select(.app_id != null and (.app_id | test($app; "i"))) | .id][0] // empty'
}

win_id="$(find_win)"

if [ -z "$win_id" ]; then
    # Not open yet: launch it on the vault. It opens at the window-rule's 0.2
    # opacity, so poll until it maps and toggle it back to full opacity.
    rm -f "$STATE"
    obsidian "$VAULT_DIR" &
    for _ in {1..40}; do
        sleep 0.1
        win_id="$(find_win)"
        if [ -n "$win_id" ]; then
            niri msg action toggle-window-rule-opacity --id "$win_id"
            exit 0
        fi
    done
    exit 0
fi

if [ -f "$STATE" ]; then
    # Hidden -> reveal it on the workspace you are looking at now.
    focused_output="$(
        niri msg -j workspaces | jq -r '.[] | select(.is_focused) | .output // empty'
    )"
    if [ -n "$focused_output" ]; then
        niri msg action move-window-to-monitor --id "$win_id" "$focused_output"
    fi
    niri msg action center-window --id "$win_id"
    niri msg action toggle-window-rule-opacity --id "$win_id"
    niri msg action focus-window --id "$win_id"
    rm -f "$STATE"
else
    # Visible -> slide to the edge, fade out, and hand focus back.
    niri msg action move-floating-window --id "$win_id" -x 100000
    niri msg action toggle-window-rule-opacity --id "$win_id"
    niri msg action focus-window-previous
    echo hidden > "$STATE"
fi
