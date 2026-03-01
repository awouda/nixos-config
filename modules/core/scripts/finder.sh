#!/usr/bin/env bash

# --hidden: find .dotfiles
# --no-ignore: find files even if they are in .gitignore (important for nix-config!)
file=$(fd . "$HOME" --hidden --no-ignore --exclude .git | fuzzel -d -p "Find: ")

if [ -n "$file" ]; then
    # Check if the file is a text file using the 'file' command
    if file --mime-type "$file" | grep -q "text/"; then
        # Open in your terminal with nvim
        alacritty -e nvim "$file"
    else
        # Use xdg-open for PDFs, images, etc.
        xdg-open "$file"
    fi
fi
