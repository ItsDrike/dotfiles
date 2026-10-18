-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local mouse_lmb = "mouse:272"
local mouse_rmb = "mouse:273"
local xf86_favorites = "code:164"

-------------------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------------------

--- Send a desktop notification
---@param title string
---@param body string
local function notify(title, body)
    hl.exec_cmd(string.format("notify-send %q %q", title, body))
end

--- Toggle SwayNC DND while retaining the explicit state-change feedback
---
--- Query SwayNC instead of keeping local state so this binding remains correct
--- when DND was changed from the control center or another client
local function toggle_notification_dnd()
    local client = io.popen("swaync-client --get-dnd --skip-wait 2>/dev/null", "r")

    if client == nil then
        return
    end

    local dnd_enabled = client:read("*l")
    client:close()

    if dnd_enabled == "false" then
        hl.exec_cmd("sh -c 'notify-send Notifications \"Pausing notifications...\" -h string:x-canonical-private-synchronous:notif-pause; sleep 2; swaync-client --dnd-on --skip-wait'")
    elseif dnd_enabled == "true" then
        hl.exec_cmd("sh -c 'swaync-client --dnd-off --skip-wait && notify-send Notifications \"Notifications enabled\" -h string:x-canonical-private-synchronous:notif-pause'")
    end
end

--- Move the active window in a given direction
---
--- Floating windows move by 100 pixels, tiled windows move within the tiling
--- layout.
---@param direction "h"|"j"|"k"|"l"
local function move_window(direction)
    local movement = ({
        h = { name = "left", x = -1, y = 0 },
        j = { name = "down", x = 0, y = 1 },
        k = { name = "up", x = 0, y = -1 },
        l = { name = "right", x = 1, y = 0 },
    })[direction]

    local window = hl.get_active_window()

    if window == nil or movement == nil then
        return
    end

    if window.floating then
        hl.dispatch(hl.dsp.window.move({
            window = window,
            x = movement.x * 100,
            y = movement.y * 100,
            relative = true,
        }))
    else
        hl.dispatch(hl.dsp.window.move({
            window = window,
            direction = movement.name,
        }))
    end
end

-------------------------------------------------------------------------------
-- Key bindings
-------------------------------------------------------------------------------

-- Active window and layout controls
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float())
hl.bind("SUPER + SHIFT + S", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pin())

-- Fullscreen variants
hl.bind("SUPER + Space", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + SHIFT + Space", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + CTRL + Space", hl.dsp.window.fullscreen_state({ internal = 2, client = 0 }))
hl.bind("SUPER + CTRL + SHIFT + Space", hl.dsp.window.fullscreen_state({ action = "toggle", internal = 0, client = 2  }))

-- Window groups.
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + SHIFT + G", hl.dsp.group.lock_active({ action = "toggle" }))
hl.bind("ALT + Tab", hl.dsp.group.next())
hl.bind("ALT + SHIFT + Tab", hl.dsp.group.prev())

-- Applications
hl.bind("SUPER + R", hl.dsp.exec_cmd("uwsm-app hyprlauncher"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd("uwsm-terminal"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("uwsm-app pcmanfm-qt"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("uwsm-app firefox"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("uwsm-app qalculate-gtk"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("uwsm-app qalculate-gtk"))

-- Focus and move tiled windows with vim-style directions
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Move the active window; floating windows move by 100 pixels
hl.bind("SUPER + ALT + h", function() move_window("h") end)
hl.bind("SUPER + ALT + j", function() move_window("j") end)
hl.bind("SUPER + ALT + k", function() move_window("k") end)
hl.bind("SUPER + ALT + l", function() move_window("l") end)

-- Numbered workspaces
for workspace = 1, 9 do
    hl.bind("SUPER + " .. workspace, hl.dsp.focus({ workspace = workspace, on_current_monitor = true }))
    hl.bind("SUPER + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = false }))
    hl.bind("ALT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }))
end

-- The unnamed special workspace (scratchpad)
hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special(""))
hl.bind("ALT + grave", hl.dsp.window.move({ workspace = "special", follow = true }))
hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({ workspace = "special", follow = false }))

-- Relative workspace/monitor movement
hl.bind("SUPER + bracketleft", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + bracketright", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER + SHIFT + bracketleft", hl.dsp.focus({ monitor = "-1" }))
hl.bind("SUPER + SHIFT + bracketright", hl.dsp.focus({ monitor = "+1" }))

-- Pointer-driven floating window manipulation
hl.bind("SUPER + " .. mouse_lmb, hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + " .. mouse_rmb, hl.dsp.window.resize(), { mouse = true })

-- Resizing windows (growing/shrinking in given direction)
hl.bind("ALT + right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("ALT + down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("ALT + h", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
hl.bind("ALT + k", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
hl.bind("ALT + j", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
hl.bind("ALT + l", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })

-- Audio / volume control
hl.bind("SUPER + Down", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-"), { repeating = true, locked = true })
hl.bind("SUPER + Up", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-"), { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Notifications
hl.bind("SUPER + period", hl.dsp.exec_cmd("swaync-client --toggle-panel --skip-wait"))
hl.bind("SUPER + SHIFT + D", toggle_notification_dnd)

-- Brightness control.
hl.bind("SUPER + Right", hl.dsp.exec_cmd("brightnessctl -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("SUPER + Left", hl.dsp.exec_cmd("brightnessctl -n2 set 5%-"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -n2 set 5%-"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -n2 set 5%+"), { repeating = true, locked = true })

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
