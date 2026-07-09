-- Enable CLI access
require("hs.ipc")

-- Mod key: Alt/Option (same physical position as Super on ThinkPad)
local mod = {"alt"}
local modShift = {"alt", "shift"}
local modCtrl = {"alt", "ctrl"}

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

-- Focus window in direction (vim-style hjkl)
hs.hotkey.bind(mod, "h", function()
    hs.window.focusedWindow():focusWindowWest(nil, true)
end)
hs.hotkey.bind(mod, "j", function()
    hs.window.focusedWindow():focusWindowSouth(nil, true)
end)
hs.hotkey.bind(mod, "k", function()
    hs.window.focusedWindow():focusWindowNorth(nil, true)
end)
hs.hotkey.bind(mod, "l", function()
    hs.window.focusedWindow():focusWindowEast(nil, true)
end)

-- Move window to half (like Sway move left/right)
hs.hotkey.bind(modShift, "h", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w / 2, screen.h))
end)
hs.hotkey.bind(modShift, "l", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen():frame()
    win:setFrame(hs.geometry.rect(screen.x + screen.w / 2, screen.y, screen.w / 2, screen.h))
end)
hs.hotkey.bind(modShift, "k", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y, screen.w, screen.h / 2))
end)
hs.hotkey.bind(modShift, "j", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen():frame()
    win:setFrame(hs.geometry.rect(screen.x, screen.y + screen.h / 2, screen.w, screen.h / 2))
end)

-- Fullscreen toggle
hs.hotkey.bind(mod, "f", function()
    local win = hs.window.focusedWindow()
    if win then win:toggleFullScreen() end
end)

-- Terminal (new window)
hs.hotkey.bind(mod, "return", function()
    local app = hs.application.find("WezTerm")
    if app then
        app:selectMenuItem({"Shell", "New Window"})
    else
        hs.application.launchOrFocus("WezTerm")
    end
end)

-- Close window
hs.hotkey.bind(modShift, "q", function()
    local win = hs.window.focusedWindow()
    if win then win:close() end
end)

-- App toggles (matching Sway)
hs.hotkey.bind(modShift, "s", function() toggleApp("KeePassXC") end)

-- Move window to next/prev screen (like Sway Mod+Ctrl+Left/Right)
hs.hotkey.bind(modCtrl, "right", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():next()) end
end)
hs.hotkey.bind(modCtrl, "left", function()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():previous()) end
end)

-- Resize mode (Alt+R enters, Escape exits)
local resizeMode = hs.hotkey.modal.new(mod, "r")

function resizeMode:entered()
    hs.alert.show("RESIZE", 1)
end

resizeMode:bind({}, "escape", function() resizeMode:exit() end)
resizeMode:bind({}, "return", function() resizeMode:exit() end)

resizeMode:bind({}, "h", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.w = f.w - 40
    win:setFrame(f)
end)
resizeMode:bind({}, "l", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.w = f.w + 40
    win:setFrame(f)
end)
resizeMode:bind({}, "k", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.h = f.h - 40
    win:setFrame(f)
end)
resizeMode:bind({}, "j", function()
    local win = hs.window.focusedWindow()
    local f = win:frame()
    f.h = f.h + 40
    win:setFrame(f)
end)

-- Reload config
hs.hotkey.bind(modShift, "r", function()
    hs.reload()
end)

-- Workspace switching (Alt+1-9 → switch to space via hs.spaces API)
for i = 1, 9 do
    hs.hotkey.bind(mod, tostring(i), function()
        local spaces = hs.spaces.spacesForScreen(hs.screen.mainScreen())
        if spaces[i] then
            hs.spaces.gotoSpace(spaces[i])
        end
    end)
end

-- Move window to space (Alt+Shift+1-9)
for i = 1, 9 do
    hs.hotkey.bind(modShift, tostring(i), function()
        local win = hs.window.focusedWindow()
        if not win then return end
        local spaces = hs.spaces.spacesForScreen(win:screen())
        if spaces[i] then
            hs.spaces.moveWindowToSpace(win, spaces[i])
            hs.spaces.gotoSpace(spaces[i])
        end
    end)
end

hs.alert.show("Hammerspoon loaded")
