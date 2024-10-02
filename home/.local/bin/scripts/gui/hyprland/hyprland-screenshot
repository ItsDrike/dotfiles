#!/bin/sh

# Inspired by grimblast (https://github.com/hyprwm/contrib/blob/main/grimblast/grimblast)

# Helper functions

die() {
	MSG="${1}"
	ERR_CODE="${2:-1}"
	URGENCY="${3:-critical}"

	>&2 echo "$MSG"
	if [ "$NOTIFY" = "yes" ]; then
		notify-send -a screenshot -u "$URGENCY" "Error ($ERR_CODE)" "$MSG"
	fi
	exit "$ERR_CODE"
}

# Argument parsing

SAVE_METHOD=
SAVE_FILE=
TARGET=
NOTIFY=no
CURSOR=no
EDIT=no
DELAY=0

while [ "${1-}" ]; do
	case "$1" in
	-h | --help)
		>&2 cat <<EOF
screenshot taking utility script, allowing for easy all-in-one solution for
controlling how a screenshot should be taken.

Methods (one is required):
    --copy: Copy the screenshot data into the clipboard
    --save [FILE]: Save the screenshot data into a file
    --copysave [FILE]: Both save to clipboard and to file
General options:
    --notify: Send a notification that the screenshot was saved
    --cursor: Capture cursor in the screenshot
    --edit: Once the screenshot is taken, edit it first with swappy
    --delay [MILISECONDS]: Wait for given time until the screenshot is taken
    --target [TARGET]: (REQUIRED) What should be captured
Variables:
    FILE: A path to a .png image file for output, or '-' to pipe to STDOUT
    MILISECONDS: Number of miliseconds; Must be a whole, non-negative number!
    TARGET: Area on screen; can be one of:
        - activewin: Currently active window
        - window: Manually select a window
        - activemon: Currently active monitor (output)
        - monitor: Manually select a monitor
        - all: Everything (all visible monitors/outputs)
        - area: Manually select a region
EOF
		exit 0
		;;
	--notify)
		NOTIFY=yes
		shift
		;;
	--cursor)
		CURSOR=yes
		shift
		;;
	--edit)
		EDIT=yes
		shift
		;;
	--target)
		if [ -z "$TARGET" ]; then
			case "$2" in
			activewin | window | activemon | monitor | all | area)
				TARGET="$2"
				shift 2
				;;
			*)
				die "Invalid target (see TARGET variable in --help)"
				;;
			esac
		else
			die "Only one target can be passed."
		fi
		;;
	--delay)
		case "$2" in
		'' | *[!0-9]*)
			die "Argument after --delay must be an amount of MILISECONDS"
			;;
		*)
			DELAY="$2"
			shift 2
			;;
		esac
		;;

	--copy)
		if [ -z "$SAVE_METHOD" ]; then
			SAVE_METHOD="copy"
			shift
		else
			die "Only one method can be passed."
		fi
		;;
	--save)
		if [ -z "$SAVE_METHOD" ]; then
			SAVE_METHOD="save"
			SAVE_FILE="$2"
			shift 2
		else
			die "Only one method can be passed."
		fi
		;;
	--copysave)
		if [ -z "$SAVE_METHOD" ]; then
			SAVE_METHOD="copysave"
			SAVE_FILE="$2"
			shift 2
		else
			die "Only one method can be passed."
		fi
		;;
	*)
		die "Unrecognized argument: $1"
		;;
	esac
done

# Screenshot functions

takeScreenshot() {
	FILE="$1"
	GEOM="$2"

	ARGS=()
	[ "$CURSOR" = "yes" ] && ARGS+=("-c")
	[ -n "$GEOM" ] && ARGS+=("-g" "$GEOM")
	ARGS+=("$FILE")

	sleep "$DELAY"e-3
	grim "${ARGS[@]}" || die "Unable to invoke grim"
}

takeEditedScreenshot() {
	FILE="$1"
	GEOM="$2"

	if [ "$EDIT" = "yes" ]; then
		takeScreenshot - "$GEOM" | swappy -f - -o "$FILE" || die "Unable to invoke swappy"
	else
		takeScreenshot "$FILE" "$GEOM"
	fi
}

# Obtain the geometry for screenshot to be taken at

if [ "$TARGET" = "area" ]; then
	GEOM="$(slurp -d)"
	if [ -z "$GEOM" ]; then
		die "No area selected" 2 normal
	fi
	WHAT="Area"
elif [ "$TARGET" = "all" ]; then
	GEOM=""
	WHAT="Screen"
elif [ "$TARGET" = "activewin" ]; then
	FOCUSED="$(hyprctl activewindow -j)"
	GEOM="$(echo "$FOCUSED" | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
	APP_ID="$(echo "$FOCUSED" | jq -r '.class')"
	WHAT="$APP_ID window"
elif [ "$TARGET" = "window" ]; then
	WORKSPACES="$(hyprctl monitors -j | jq -r 'map(.activeWorkspace.id)')"
	WINDOWS="$(hyprctl clients -j | jq -r --argjson workspaces "$WORKSPACES" 'map(select([.workspace.id] | inside($workspaces)))')"
	GEOM=$(echo "$WINDOWS" | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' | slurp -r)
	if [ -z "$GEOM" ]; then
		die "No window selected" 2 normal
	fi
	WHAT="Window"
elif [ "$TARGET" = "activemon" ]; then
	ACTIVEMON="$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')"
	GEOM="$(echo "$ACTIVEMON" | jq -r '"\(.x),\(.y) \(.width)x\(.height)"')"
	WHAT="$(echo "$ACTIVEMON" | jq -r '.name')"
elif [ "$TARGET" = "monitor" ]; then
	GEOM="$(slurp -o)"
	if [ -z "$GEOM" ]; then
		die "No monitor selected" 2 normal
	fi
	WHAT="Monitor"
else
	if [ -z "$TARGET" ]; then
		die "No target specified!"
	else
		die "Unknown target: $SAVE_METHOD"
	fi
fi

# Invoke grim and capture the screenshot

if [ "$SAVE_METHOD" = "save" ]; then
	takeEditedScreenshot "$SAVE_FILE" "$GEOM"
	[ "$NOTIFY" = "yes" ] && notify-send -a screenshot "Success" "$WHAT screenshot saved" -i "$(realpath "$SAVE_FILE")"
elif [ "$SAVE_METHOD" = "copy" ]; then
	TEMP_FILE="$(mktemp --suffix=.png)"
	takeEditedScreenshot "-" "$GEOM" | tee "$TEMP_FILE" | wl-copy --type image/png || die "Clipboard error"
	[ "$NOTIFY" = "yes" ] && notify-send -a screenshot "Success" "$WHAT screenshot copied" -i "$(realpath "$TEMP_FILE")" && rm "$TEMP_FILE"
elif [ "$SAVE_METHOD" = "copysave" ]; then
	takeEditedScreenshot "-" "$GEOM" | tee "$SAVE_FILE" | wl-copy --type image/png || die "Clipboard error"
	[ "$NOTIFY" = "yes" ] && notify-send -a screenshot "Success" "$WHAT screenshot copied and saved" -i "$(realpath "$SAVE_FILE")"
else
	if [ -z "$SAVE_METHOD" ]; then
		die "No save method specified!"
	else
		die "Unknown save method: $SAVE_METHOD"
	fi
fi
