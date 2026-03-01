#!/usr/bin/env bash
# Get all windows, format them for Fuzzel, and focus the selected one
window=$(swaymsg -t get_tree | jq -r '
  .. 
  | select(.type? == "con" and .name?) 
  | "\(.name) | \(.app_id // .window_properties.class) (\(.id))"' \
  | fuzzel -d -p "Window: ")

if [ -n "$window" ]; then
  # Extract the ID from the parentheses at the end of the string
  id=$(echo "$window" | sed 's/.*(\([0-9]*\))/\1/')
  swaymsg "[con_id=$id] focus"
fi
