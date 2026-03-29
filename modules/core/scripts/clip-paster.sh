#!/usr/bin/env bash

# 1. Pick the item
selected=$(cliphist list | fuzzel --dmenu --width 60 --lines 10)
[[ -z "$selected" ]] && exit 0

# 2. Extract RAW content
raw_content=$(echo "$selected" | cliphist decode)

# 3. Put it in the clipboard (Cruciaal voor ydotool methode)
echo -n "$raw_content" | wl-copy

# 4. De "Focus" Delay
# Geef het actieve venster (IntelliJ/Chrome) even de tijd om de focus te pakken
sleep 0.2

# 5. THE FIX: Gebruik ydotool om Ctrl+V te simuleren
# Dit "plakt" de hele buffer in één keer in plaats van te typen.
ydotool key 29:1 47:1 47:0 29:0
