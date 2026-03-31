#!/usr/bin/env bash

# 1. Pick the item
selected=$(cliphist list | fuzzel --dmenu --width 60 --lines 10)
[[ -z "$selected" ]] && exit 0

# 2. Extract RAW content
raw_content=$(echo "$selected" | cliphist decode)

# 3. Put it in the clipboard (The "Package")
echo -n "$raw_content" | wl-copy

# 4. Small delay to let the clipboard buffer settle
sleep 0.1

# 5. THE REAL FIX: Trigger a Paste Event
# Instead of typing the string, we send the "Paste" shortcut.
# For Linux/Sway:
wtype -M ctrl v -m ctrl

