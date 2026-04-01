#!/usr/bin/env bash

# 1. Pick the item from history
selected=$(cliphist list | fuzzel --dmenu --width 60 --lines 10)

# 2. If nothing was selected (Esc/Ctrl-C), exit cleanly
[[ -z "$selected" ]] && exit 0

# 3. The "Manual" Fix: Just put it in the clipboard and stop.
# We remove the 'wtype' and 'sleep' entirely.
echo "$selected" | cliphist decode | wl-copy
