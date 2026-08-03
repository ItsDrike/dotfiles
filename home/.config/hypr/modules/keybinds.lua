---@param title string
---@param body string
local function notify(title, body)
    hl.exec_cmd(string.format("notify-send %q %q", title, body))
end

local mouse_lmb = "mouse:272"
local mouse_rmb = "mouse:273"
local xf86_favorites = "code:164"

-- Active window.
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float())
hl.bind("SUPER + SHIFT + S", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pin())

-- DE / WM control.
hl.bind("SUPER + CTRL + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("uwsm app -- wlogout -p layer-shell"))
hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("toggle-idle"))

-- Programs.
hl.bind("SUPER + R", hl.dsp.exec_cmd("nc -U /run/user/$UID/walker/walker.sock"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd("uwsm app -- kitty"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("uwsm app -- pcmanfm-qt"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("uwsm app -- firefox"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("uwsm app -- qalculate-gtk"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("uwsm app -- qalculate-gtk"))
hl.bind("SUPER + SHIFT + V", hl.dsp.exec_cmd("uwsm app -- cliphist list | walker -d | cliphist decode | wl-copy"))

-- Fullscreen variants.
hl.bind("SUPER + Space", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + CTRL + Space", hl.dsp.window.fullscreen_state({ internal = 2, client = 0 }))
hl.bind("SUPER + CTRL + SHIFT + Space", hl.dsp.window.fullscreen_state({ internal = 1, client = 2 }))
hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("toggle-fake-fullscreen"))

-- Audio / volume control.
hl.bind("SUPER + Down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"), { repeating = true, locked = true })
hl.bind("SUPER + Up", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"), { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Notifications.
hl.bind("CTRL + grave", hl.dsp.exec_cmd("swaync-client --close-latest"))
hl.bind("CTRL + SHIFT + grave", hl.dsp.exec_cmd("swaync-client --close-all"))
hl.bind("CTRL + ALT + grave", hl.dsp.exec_cmd("swaync-client --hide-latest"))
hl.bind("CTRL + period", hl.dsp.exec_cmd("swaync-client --toggle-panel"))
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("toggle-notifications"))

-- Brightness control.
hl.bind("SUPER + Right", hl.dsp.exec_cmd("brightnessctl -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("SUPER + Left", hl.dsp.exec_cmd("brightnessctl -n2 set 5%-"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -n2 set 5%-"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -n2 set 5%+"), { repeating = true, locked = true })

-- Screenshots.
local screenshot_format = "${XDG_SCREENSHOTS_DIR:-$HOME/Media/Pictures/Screenshots}/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
local screenshot_delay = 2000
local printscr_key = "Print"

hl.bind(printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --copy --target area"))
-- Dangerous when enabled: lockscreen screenshots.
-- hl.bind(printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --copy --target all"), { locked = true })
hl.bind("SUPER + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --copy --target area --edit"))
hl.bind("SHIFT + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --save " .. screenshot_format .. " --target area"))
hl.bind("CTRL + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --copy --target area --delay " .. screenshot_delay))
hl.bind("SUPER + SHIFT + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --save " .. screenshot_format .. " --target area --edit"))
hl.bind("SUPER + CTRL + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --copy --target area --delay " .. screenshot_delay .. " --edit"))
hl.bind("SUPER + SHIFT + CTRL + " .. printscr_key, hl.dsp.exec_cmd("hyprland-screenshot --notify --save " .. screenshot_format .. " --target area --delay " .. screenshot_delay .. " --edit"))
hl.bind("ALT + " .. printscr_key, hl.dsp.exec_cmd("walker -m \"menus:screenshots\""))

-- XF86Favorites key for recording.
hl.bind(xf86_favorites, hl.dsp.exec_cmd("uwsm app -- quick-record --notify toggle"))
hl.bind("SUPER + " .. xf86_favorites, hl.dsp.exec_cmd("uwsm -- app quick-record toggle"))

-- Window groups.
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT + G", hl.dsp.group.lock_active({ action = "toggle" }))
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("ALT + grave", hl.dsp.group.prev())

-- Special workspace / scratchpad. Empty name means the unnamed special workspace.
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special(""))
hl.bind("ALT + grave", hl.dsp.window.move({ workspace = "special", follow = true }))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special", follow = false }))

-- Move focus.
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Move floating or active windows via your helper script.
local float_move_size = 100
hl.bind("SUPER + ALT + h", hl.dsp.exec_cmd("hyprland-move-window " .. float_move_size .. " l"))
hl.bind("SUPER + ALT + l", hl.dsp.exec_cmd("hyprland-move-window " .. float_move_size .. " r"))
hl.bind("SUPER + ALT + k", hl.dsp.exec_cmd("hyprland-move-window " .. float_move_size .. " u"))
hl.bind("SUPER + ALT + j", hl.dsp.exec_cmd("hyprland-move-window " .. float_move_size .. " d"))

-- Workspaces.
for workspace = 1, 9 do
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace, on_current_monitor = true }))
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = false }))
    hl.bind("ALT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

hl.bind("SUPER + bracketleft", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.focus({ monitor = "-1" }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.focus({ monitor = "+1" }))

-- Window moving / resizing.
hl.bind("SUPER + " .. mouse_lmb, hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + " .. mouse_rmb, hl.dsp.window.resize(), { mouse = true })

hl.bind("ALT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("ALT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("ALT + h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("ALT + j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("ALT + l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })

-- Global keybind passed to OBS.
hl.bind("CTRL + F10", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))

-- Keybind isolation submap for games or apps that should receive most keys.
hl.bind("SUPER + End", function()
    hl.dispatch(hl.dsp.submap("isolate"))
    notify("Keybind isolation", "Keybind isolation on (Super + END to disable)")
end)

hl.define_submap("isolate", function()
    hl.bind("SUPER + End", function()
        hl.dispatch(hl.dsp.submap("reset"))
        notify("Keybind isolation", "Keybind isolation off")
    end)
end)
