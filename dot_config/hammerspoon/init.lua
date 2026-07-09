-- Enable CLI access
require("hs.ipc")

-- Toggle app: bring to front or hide if already focused
local function toggleApp(appName)
    local app = hs.application.find(appName)
    if app then
        if app:isFrontmost() then
            app:hide()
        else
            app:activate()
        end
    else
        hs.application.launchOrFocus(appName)
    end
end

-- Keybindings (matching Sway patterns)
-- Cmd+Shift+S: Toggle KeePassXC
hs.hotkey.bind({"cmd", "shift"}, "s", function() toggleApp("KeePassXC") end)

-- Reload config
hs.hotkey.bind({"cmd", "shift"}, "r", function()
    hs.reload()
end)

hs.alert.show("Hammerspoon loaded")
