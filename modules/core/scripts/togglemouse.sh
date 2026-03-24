#!/usr/bin/env bash
# Get the current left_handed status of the pointer
CURRENT_STATUS=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "pointer") | .libinput.left_handed' | head -n 1)

if [ "$CURRENT_STATUS" == "enabled" ]; then
    swaymsg input "type:pointer" left_handed disabled
    echo "Mouse set to right-handed mode"
else
    swaymsg input "type:pointer" left_handed enabled
    echo "Mouse set to left-handed mode"
fi
