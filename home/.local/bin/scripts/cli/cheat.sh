#!/bin/sh

# rm_trailing_slashes(string)
#
# Prints a string without any trailing slashes.
# This is used because cheat.sh doesn't play nicely with multiple slashes in
# URLs.
rm_trailing_slashes() {
    string="$1"
    last_char="$(printf "$string" | tail -c 1)"
    if [ "$last_char" = "/" ]; then
        echo "$(rm_trailing_slashes "${string%?}")"
    else
        echo "$string"
    fi
}

# pick_category(must_match, query, argument, recurse)
#
# Pick cheat.sh category.
# if must_match is 1, only allow listed options to be picked.
# if query is specified, pick sub-category of it, else pick global categories.
# if argument is specified, optionally perform must_match check and print it.
# if recurse is 1, if the selected option ends with /, run the function again.
#
# Prints the chosen category
pick_category() {
    must_match="$1"
    query="$(rm_trailing_slashes "$2")"
    argument="$3"
    recurse="$4"

    # Query all possible options
    if [ -n "$query" ]; then
        url="cheat.sh/$query/:list"
    else
        url="cheat.sh/:list"
    fi
    selectable="$(curl -s "$url")"

    # If argument is specified, print it, optionally perform must_match check.
    if [ -n "$argument" ]; then
        if [ "$must_match" -ne 1 ] || echo "$selectable" | grep -qe "\b$1\b"; then
            selected="$argument"
        else
            echo "Invalid selection: '$argument'"
            echo "For all selections, query $url"
            exit 1
        fi
    # Select the option with fzf, optionally allow other matches if must_match isn't set.
    else
        if [ "$must_match" -ne 1 ]; then
            if [ -z "$selectable" ]; then
                header="No selections found, you can use empty query to show category help, or type a custom query."
            else
                header="Use alt-enter to enter non-listed query. You can use empty queries to show category help."
            fi
            selected="$(printf "\n$selectable" | \
                fzf --bind=alt-enter:print-query \
                --print-query \
                --prompt="cheat.sh/$query query>" \
                --header="$header"\
                )"
        else
            selected=$(printf "$selectable" | fzf --prompt="cheat.sh/$query category>")
            if [ $? -ne 0 ]; then
                echo "Invalid selection: '$selected'"
                echo "For all selections, query $url"
                exit 1
            fi
        fi
        selected=$(printf "$selected" | tail -1)
    fi


    # Replace spaces with '+' (cheat.sh resolves those as spaces)
    selected="$(echo "$selected" | tr ' ' '+')"

    # Prepend the original query, if we have one
    # Print the selected category, or subcategory with the category
    if [ -n "$query" ]; then
        result="$query/$selected"
    else
        result="$selected"
    fi

    # Recurse, if specified and the result ended with /
    if [ "$recurse" -eq 1 ]; then
        if [ "$(printf "$selected" | tail -c 1)" = "/" ]; then
            result="$(pick_category "$must_match" "$result" "$argument" 1)"
        fi
    fi

    # Print the result
    printf "$result"
}

# Select the cheatsheat category (language/core-util/...)
query=$(pick_category 1 "" "$1" 0)

# If the query isn't already complete, select a sub-category
if ! echo "$query" | grep -qe ":"; then
    query="$(pick_category 0 "$query" "$2" 1)"
fi

# Construct the URL from given query and print it
url="cheat.sh/$query"
echo "$url"

# Show the output of cheat.sh request
curl -s "$url"
