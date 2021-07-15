#!/bin/sh

if [ $# -lt 1 ]; then
    echo "Invalid amount of arguments passed!"
    echo "Required parameter: amount of monitors"
    exit
fi

MONITOR_AMOUT="$1"
WIDTH=1920
WORK_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xmobar"

make_position_line(){
    xpos=$(($1 * $WIDTH))
    line=", position = Static { xpos = $xpos, ypos = 0, width = $WIDTH, height = 24 }"
    echo "$line"
}


# Remove all already existing specific xmobar configurations
find $WORK_DIR -regex '\./xmobarrc[0-9]+' -exec rm {} +

xmobarhs_content="$(cat $WORK_DIR/xmobarrc.hs)"
position_line_0="$(make_position_line 0)"

for ((n=0;n<MONITOR_AMOUT;n++)); do
    cur_file="$WORK_DIR/xmobarrc$n"

    # Replace position line to accomodate for multiple monitors
    position_line="$(make_position_line $n)"
    contents="${xmobarhs_content/$position_line_0/$position_line}"

    # Only keep trayer spacer in 1st xmobar
    if [ $n -ne 0 ]; then
        #contents="${contents/'%trayerpad%'/''}"
        contents="$(grep -v trayerpad <<< $contents)"
    fi

    echo "$contents" > "$cur_file"
    echo "$cur_file created."
done
