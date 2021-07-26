#!/bin/sh
# This script handles showing file-previews within lf.
# It can also show image previews using ueberzug, however
# that requires lf to be start with a script that also starts
# ueberzug alongside of it.
# (In my dotfiles, this script is in '~/.local/bin/scripts/lfu')

run_cmd() {
    # Try to run given command, if it is installed.
    # If it isn't try to fallback to text_handle,
    # otherwise fail completely.
    cmd="$1"
    shift

    if command -v "$cmd" > /dev/null; then
        $cmd $@
    else
        # If we didn't found the requested command, check if
        # the file is text-like and try to use the text_handle
        # to show the preview, this may not be ideal for given
        # file-format, but at least we won't fail.
        case $(file --mime-type "$1" -bL) in
            # TODO: Consider checking for UTF-8 formatting instead,
            # or show previews for any file-type
            text/*|application/json)
                echo "@@PREVIEW FALLBACK: Using text handle, $cmd command not found!"
                text_handle "$1"
                ;;
            *)
                echo "@@PREVIEW ERROR: Preview failed, $cmd command not found!"
                ;;
        esac
    fi
}

draw_image() {
    # Draw passed image with use of given draw_script.
    # If the image contains EXIF (metadata) orientation info,
    # handle it and draw the rotated image.
    draw_script="$1"
    file="$2"
    shift
    shift

    # Calculate where the image should be placed on the screen.
    num=$(printf "%0.f\n" "`echo "$(tput cols) / 2" | bc`")
    numb=$(printf "%0.f\n" "`echo "$(tput cols) - $num - 1" | bc`")
    numc=$(printf "%0.f\n" "`echo "$(tput lines) - 2" | bc`")

    # Handle EXIF (metadata) orientation.
    exif_orientation="$(identify -format '%[EXIF:Orientation]\n' -- "$file")"
    if [ -n "$exif_orientation" ] && [ "$exif_orientation" != 1 ]; then
        # In case `convert` command isn't aviable, ignore EXIF rotation
        if command -v convert > /dev/null; then
            cache=$(mktemp /tmp/thumbcache.XXXXX)
            convert -- "$file" -auto-orient "$cache"
            $draw_script "$cache" $num 1 $numb $numc
        else
            $draw_script "$file" $num 1 $numb $numc
        fi
    else
        $draw_script "$file" $num 1 $numb $numc
    fi

    # Exit with status code 1 to signal lf that the function
    # should be re-ran next time instead of caching the result.
    exit 1
}

media_handle() {
    # Handle media type files (videos, photos). These types of
    # files are usually not stored in any form of textually readable
    # format and they require a special way of displaying them.
    # This mostly uses ueberzug (if available) for this.

    draw_script="${XDG_CONFIG_HOME:-$HOME/.config}/lf/draw_img.sh"
    file="$1"
    shift

    # Set ENABLED=1 if ueberzug is enabled
    [ -n "$FIFO_UEBERZUG" ] && [ -f "$draw_script" ] && ENABLED=1

    case "$file" in
        *.bmp|*.jpg|*.jpeg|*.png|*.xpm)
            if [ -n "$ENABLED" ]; then
                draw_image $draw_script "$file"
            else
                echo "@@PREVIEW FALLBACK: Using mediainfo, ueberzug isn't aviable."
                run_cmd mediainfo "$file"
            fi
            ;;
        *.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|\
        *.mov|*.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx)
            if [ -n "$ENABLED" ]; then
                cache="$(mktemp /tmp/thumbcache.XXXXX)"
                ffmpegthumbnailer -i "$file" -o "$cache" -s 0
                draw_image $draw_script "$cache"
            else
                echo "@@PREVIEW FALLBACK: Using exiftool, ueberzug isn't aviable."
                run_cmd exiftool "$file"
            fi
            ;;
        *.wav|*.mp3|*.flac|*.m4a|*.wma|*.ape|*.ac3|*.og[agx]|*.spx|*.opus|*.as[fx]|*.flac)
            # These types can't make use of ueberzug easily, so simply use eixftool
            run_cmd exiftool "$file"
            ;;
        *)
            echo "@@PREVIEW FALLBACK: Unrecognized media file, falling back to text handle."
            text_handle "$file"
            ;;
    esac
}

text_handle() {
    # Handle all other formats as text and cat them
    # if highlighting tools are aviable, try to use them
    if command -v bat > /dev/null; then
        bat -pp --color=always "$1"
    elif command -v highlight > /dev/null; then
        highlight "$1" --out-format ansi --force
    else
        cat "$1"
    fi
}

# Capture all directories at first, since they could
# potentionally match one of the file case statements
if [ -d "$1" ]; then
    tree "$1" -La 1
elif [ -f "$1" ]; then
    case "$1" in
        *.tgz|*.tar.gz) run_cmd tar tzf "$1";;
        *.tar.bz2|*.tbz2) run_cmd tar tjf "$1";;
        *.tar.txz|*.txz) run_cmd xz --list "$1";;
        *.tar) run_cmd tar tf "$1";;
        *.zip|*.jar|*.war|*.ear|*.oxt) run_cmd unzip -l "$1";;
        *.rar) run_cmd unrar l "$1";;
        *.7z) run_cmd 7z l "$1";;
        *.iso) run_cmd iso-info --no-header -l "$1";;
        *.o) run_cmd nm "$1" | less ;;
        *.csv) cat "$1" | sed s/,/\\n/g ;;
        *odt,*.ods,*.odp,*.sxw) run_cmd odt2txt "$1";;
        *.doc) run_cmd catdoc "$1" ;;
        *.docx) run_cmd docx2txt "$1" - ;;
        *.torrent) run_cmd transmission-show "$1";;
        *.pdf) run_cmd pdftotext "$1";;
        *.wav|*.mp3|*.flac|*.m4a|*.wma|*.ape|*.ac3|*.og[agx]|*.spx|*.opus|*.as[fx]|*.flac|\
        *.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|*.mov|\
        *.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx|\
        *.bmp|*.jpg|*.jpeg|*.png|*.xpm) media_handle "$1" ;;
        *) text_handle "$1" ;;
    esac
fi
