# Get the selected item from cliphist
selected=$(cliphist list | rofi -dmenu)

# Exit if nothing was selected (user pressed Esc)
if [ -z "$selected" ]; then
    exit 0
fi

# Decode and copy to wayland clipboard
echo "$selected" | cliphist decode | wl-copy

# The Wayland Magic: Wait a fraction of a second for Rofi to close 
# so your target window regains focus, then simulate Shift+Insert (Universal Paste)
sleep 0.05
wtype -M shift -k Insert -m shift
