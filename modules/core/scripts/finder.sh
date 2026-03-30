#!/usr/bin/env bash

# fd finds files, awk prepends the name: "filename.jpg  |  /home/user/photos/filename.jpg"
selection=$(fd . "$HOME" --hidden --no-ignore --exclude .git --type f | \
    awk -F/ '{print $NF "  |  " $0}' | \
    fuzzel -d -p "Find: " --width 100)

[[ -z "$selection" ]] && exit

# Extract path from everything after the separator
file=$(echo "$selection" | sed 's/.* |  //')

if [ -n "$file" ]; then
    if file --mime-type "$file" | grep -q "text/"; then
        # Matches the 'floating_finder' rule in your Sway config
        alacritty --class "floating_finder" -e nvim "$file"
    else
        xdg-open "$file"
    fi
fi

