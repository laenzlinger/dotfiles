-- Vim-style navigation (consistent with zathura)
-- Next/previous image
swayimg.viewer.on_key("l", function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("h", function() swayimg.viewer.switch_image("prev") end)

-- Pan image
swayimg.viewer.on_key("j", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y - wnd.height / 10))
end)
swayimg.viewer.on_key("k", function()
  local wnd = swayimg.get_window_size()
  local pos = swayimg.viewer.get_position()
  swayimg.viewer.set_abs_position(pos.x, math.floor(pos.y + wnd.height / 10))
end)

-- First/last image
swayimg.viewer.on_key("g", function() swayimg.viewer.switch_image("first") end)
swayimg.viewer.on_key("Shift-g", function() swayimg.viewer.switch_image("last") end)

-- Zoom reset
swayimg.viewer.on_key("0", function() swayimg.viewer.reset() end)
