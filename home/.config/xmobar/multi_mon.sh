#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Invalid amount of arguments passed!"
    echo "Required parameter: amount of monitors"
    exit
fi

MONITOR_AMOUT="$1"
WIDTH=1920
WORK_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xmobar"

make_line(){
    xpos=$(($1 * $WIDTH))
    line=", position = Static { xpos = $xpos, ypos = 0, width = $WIDTH, height = 24 }"
    echo "$line"
}


# Remove all already existing specific xmobar configurations
find $WORK_DIR -regex '\./xmobarrc[0-9]+' -exec rm {} +

for ((n=0;n<MONITOR_AMOUT;n++)); do
    cur_file="$WORK_DIR/xmobarrc$n"
    sed "s/$(make_line 0)/$(make_line $n)/g" "$WORK_DIR/xmobarrc.hs" > "$cur_file"
    echo "$cur_file created."
done
