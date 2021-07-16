-- xmobar main configuration file
--
-- This file serves as a shared template for the specific xmonad
-- configuration files that are generated from this file to accomodate
-- for multiple monitors.
--
-- For more details, run 'man xmobar', or visit the project website
-- http://projects.haskell.org/xmobar/

Config {
-- Set font for default dg/bg colors. xmobar height will
-- be controlled by this font (it'll adjust itself to accomodate it)
-- Additional fonts can be defined for emoji support
font = "xft:Ubuntu:weight=bold:pixelsize=11:antialias=true:hinting=true",
additionalFonts = [
        "xft:Font Awesome 5 Free Solid:pixelsize=12",
        "xft:Font Awesome 5 Brands:pixelsize=12",
        "xft:Mononoki Nerd Font:pixelsize=11:antialias=true:hinting=true"
],
bgColor = "#282c34",
fgColor = "#ff6c6b",

-- Define static position that will be adjusted by the deploy script
-- which will tweak the starting positions for multiple monitors, this
-- configuration will work fine for single monitor systems out of the box.
position = Static { xpos = 0, ypos = 0, width = 1920, height = 24 },
-- Define the place where all used XPM images will be stored in
-- Apparently there's is no way to use env var or relpaths here.
iconRoot = "/home/itsdrike/.config/xmobar/xpm",
-- list of commands which gather information about the system
-- which can then be referrenced in the final template string
commands = [
        -- Gather and format CPU usage information
        -- if it's above 50%, we consider it high and make it red
        Run Cpu [
        "-t", "<fn=1>\xf108</fn>  cpu: <total>%",
        "-H","50",
        "--high","red"
        ] 20,

        -- Ram used number and percent
        Run Memory ["-t", "<fn=1>\xf233</fn>  mem: <used>M (<usedratio>%)"] 20,

        -- Battery information. This is likely to require some customization
        -- based upon your specific hardware. Or, for a desktop you may want
        -- to just remove this section entirely.
        Run Battery [
        "-t", "<fn=1>\xf240</fn> <acstatus> <left>% - <timeleft>",
        "--",
        "-i", "<fc=#75c44c>AC</fc>",
        "-O", "<fc=#75c44c>AC</fc>",
        "-o", "<fc=#ff0000>AUX</fc>",
        "-L", "12",
        "-h", "green",
        "-l", "red"
        ] 10,

        -- Time and date
        Run Date "<fn=1>\xf017</fn>  %H:%M %b %d %Y" "date" 50,

        -- Network up and down
        Run Network "wlp2s0" ["-t", "<fn=1>\xf0ab</fn>  <rx>kb  <fn=1>\xf0aa</fn>  <tx>kb"] 20,
        --Run Network "enp3s0" ["-t", "<fn=1>\xf0ab</fn>  <rx>kb  <fn=1>\xf0aa</fn>  <tx>kb"] 20,

        -- Show free disk space on /
        Run DiskU [("/", "<fn=1>\xf0c7</fn>  hdd: <free>")] [] 60,

        -- Get kernel version from uname -r
        Run Com "uname" ["-r"] "" 3600,

        -- Add dynamic invisible XPM icon that resizes to accomodate trayer
        -- this needs to be an absolute string path, env vars or relpaths aren't accepted
        -- this should only be on 1 monitor (single file), so ignore this comment on others
        Run Com "/home/itsdrike/.config/xmobar/trayer-padding-icon.sh" [] "trayerpad" 10,

        -- This line tells xmobar to read input from stdin.
        -- That's how it gets information that xmonad is sending
        -- (such as workspaces) for displaying.
        -- By using UnsafeStdinReader, it also allows mouse clicking events
        Run UnsafeStdinReader
],

-- Separator character used to wrap variables in the xmobar template string
sepChar = "%",
-- Alignment eparator character used in the xmobar template string.
-- Everything before this will be aligned left, everything after right.
alignSep = "}{",

-- Template string defining the xmobar contents and overall layout.
template = "\
    \<icon=haskell_20.xpm/>   \
    \<fc=#666666>|</fc> %UnsafeStdinReader% }{ \
    \<fc=#666666>|</fc>  <fc=#b3afc2><fn=2></fn>  %uname% </fc> \
    \<fc=#666666>|</fc>  <fc=#9ce996> %battery% </fc> \
    \<fc=#666666>|</fc>  <fc=#ecbe7b> %cpu% </fc> \
    \<fc=#666666>|</fc>  <fc=#ff6c6b> %memory% </fc> \
    \<fc=#666666>|</fc>  <fc=#51afef> %disku% </fc> \
    \<fc=#666666>|</fc>  <fc=#98be65> %wlp2s0% </fc> \
    --\<fc=#666666>|</fc>  <fc=#98be65> %eth3s0% </fc> \
    \<fc=#666666>|</fc>  <fc=#46d9ff> %date% </fc> \
    \<fc=#666666>|</fc>  %trayerpad%\
    \ "
}


