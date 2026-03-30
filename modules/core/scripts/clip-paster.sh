#!/usr/bin/env bash

# 1. Pick the item
selected=$(cliphist list | fuzzel --dmenu --width 60 --lines 10)
[[ -z "$selected" ]] && exit 0

# 2. Extract RAW content (preserves newlines perfectly)
raw_content=$(echo "$selected" | cliphist decode)

# 3. Put it in the clipboard (for Chrome/IDE use)
echo "$raw_content" | wl-copy

# 4. The "Solid" Delay
sleep 0.2

# 5. THE FIX: Type it out directly
# This bypasses the terminal's refusal to "paste"
wtype "$raw_content"
