#!/bin/sh
languages=`echo "python rust golang lua cpp c typescript nodejs javascript js" | tr ' ' '\n'`
core_utils=`echo "xargs find sed awk" | tr ' ' '\n'`

selected=`printf "$languages\n$core_utils" | fzf`
read -p "query: " query
query=`echo "$query" | tr ' ' '+'`


if printf "$languages" | grep -qs "$selected"; then
    url="cheat.sh/$selected/$query"
else
    url="cheat.sh/$selected~$query"
fi

curl "$url"
