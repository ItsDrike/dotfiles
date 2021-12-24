#!/bin/sh

# Select the cheatsheat
SELECTABLE="$(curl -s "cheat.sh/:list")"
if [ -n "$1" ]; then
    if echo "$SELECTABLE" | grep -qe "\b$1\b"; then
        selected="$1"
    else
        echo "Invalid selection. For all selections, query cheat.sh/:list"
        exit 1
    fi
else
    selected=$(printf "$SELECTABLE" | fzf)
    if [ $? -ne 0 ]; then
        echo "Invalid selection: '$selected'"
        exit 1
    fi
    selected=$(printf "$selected" | tail -1)
fi

# If the cheatsheet doesn't already include a query, select a query
if echo "$selected" | grep -qe "[/:]"; then
    query=""
elif [ -n "$2" ]; then
    query="$2"
else
    options=$(curl -s "cheat.sh/$selected/:list")
    query="$(printf "\n$options" | \
        fzf --bind=alt-enter:print-query \
        --prompt="cheat.sh query>" \
        --header="use alt-enter to enter non-listed query"\
        )"
    query=$(echo "$query" | tail -1)
fi
query="$(echo "$query" | tr ' ' '+')"

# cheat.sh doesn't play nicely with trailing / in URLs
if [ -n "$query" ]; then
    url="cheat.sh/$selected/$query"
else
    url="cheat.sh/$selected"
fi

# Print the URL and make the request
echo "$url"
curl -s "$url"
