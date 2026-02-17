# We use "$@" here so that if you type 'fshow --author=Alex', 
# the '--author=Alex' part gets injected into the git log command.

git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | \
fzf --ansi --no-sort --reverse --tiebreak=index \
    --bind "ctrl-s:toggle-sort" \
    --preview 'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
    --header "enter to view, ctrl-o to checkout" \
    --bind "q:abort,ctrl-f:preview-page-down,ctrl-b:preview-page-up" \
    --bind "ctrl-o:become:(echo {} | grep -o '[a-f0-9]\{7\}' | head -1 | xargs git checkout)" \
    --preview-window=right:60%
