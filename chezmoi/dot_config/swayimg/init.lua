-- Keep the viewing window focused entirely on the image
swayimg.decoration = false
swayimg.text.visible = false
swayimg.text.status_timeout = 3
swayimg.viewer.text = {}

-- Start at 100% unless that would exceed the window, then fit the image
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.autocenter = false

-- Include sibling images when Swayimg is opened with one image file
swayimg.imagelist.adjacent = true

local function zoom_by(factor)
  local mouse = swayimg.get_mouse_pos()
  local scale = swayimg.viewer.scale
  swayimg.viewer.set_abs_scale(scale + scale * factor, mouse.x, mouse.y)
end

-- Zoom without a modifier, centered on the pointer
swayimg.viewer.on_mouse("ScrollUp", function()
  zoom_by(0.1)
end)
swayimg.viewer.on_mouse("ScrollDown", function()
  zoom_by(-0.1)
end)

-- Keypad + does not report Shift on this keyboard layout
swayimg.viewer.on_key("KP_Add", function()
  zoom_by(0.1)
end)

-- Use the cursor keys to browse; reserve the keypad for panning
swayimg.viewer.on_key("Left", function()
  swayimg.viewer.open("prev")
end)
swayimg.viewer.on_key("Right", function()
  swayimg.viewer.open("next")
end)

-- Show the current filename without enabling the metadata overlay
swayimg.viewer.on_key("i", function()
  local image = swayimg.viewer.get_image()
  if image then
    swayimg.text.status = image.path:match("[^/]+$")
  end
end)

-- Reset scale and pan to the normal opening view
swayimg.viewer.on_key({ "0", "KP_0", "KP_Insert", "KP_5", "KP_Begin" }, function()
  swayimg.viewer.reset()
end)

local function pan_by(x, y)
  local position = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(position.x + x, position.y + y)
end

-- Support the numpad with NumLock either on or off
swayimg.viewer.on_key({ "KP_4", "KP_Left" }, function()
  pan_by(50, 0)
end)
swayimg.viewer.on_key({ "KP_6", "KP_Right" }, function()
  pan_by(-50, 0)
end)
swayimg.viewer.on_key({ "KP_8", "KP_Up" }, function()
  pan_by(0, 50)
end)
swayimg.viewer.on_key({ "KP_2", "KP_Down" }, function()
  pan_by(0, -50)
end)
