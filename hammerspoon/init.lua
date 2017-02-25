-- remap functions

local function keyCode(key, mods, callback)
  mods = mods or {}
  callback = callback or function() end
  return function()
    hs.eventtap.event.newKeyEvent(mods, string.lower(key), true):post()
    hs.timer.usleep(1000)
    hs.eventtap.event.newKeyEvent(mods, string.lower(key), false):post()
    callback()
  end
end

local function remapKey(mods, key, keyCode)
  hs.hotkey.bind(mods, key, keyCode, nil, keyCode)
end

local function killLine()
  return keyCode("right", {"cmd", "shift"}, keyCode("x", {"cmd"}))
end

-- watch & switch hotkey settings

local function switchHotKeys(enable)
  for k, v in pairs(hs.hotkey.getHotkeys()) do
    if enable then
      v["_hk"]:enable()
    else
      v["_hk"]:disable()
    end
  end
end

-- local function handleGlobalEvent(name, event, app)
--   if event == hs.application.watcher.activated then
--     if name == "Emacs" or name == "iTerm2" then
--       switchHotKeys(false)
--     else
--       switchHotKeys(true)
--     end
--   end
-- end

-- watcher = hs.application.watcher.new(handleGlobalEvent)
-- watcher:start()


-- remap settings
-- Cursor
remapKey({"ctrl"}, "p", keyCode("up"))
remapKey({"ctrl"}, "n", keyCode("down"))
remapKey({"ctrl"}, "f", keyCode("right"))
remapKey({"ctrl"}, "b", keyCode("left"))
-- remapKey({"ctrl", "option"}, "p", keyCode("up", {"option"}))
-- remapKey({"ctrl", "option"}, "n", keyCode("down", {"option"}))
-- remapKey({"option"}, "f", keyCode("right", {"option"}))
-- remapKey({"option"}, "b", keyCode("left", {"option"}))
-- remapKey({"ctrl", "cmd"}, "f", keyCode("right", {"shift"}))
-- remapKey({"ctrl", "cmd"}, "b", keyCode("left", {"shift"}))
--
-- remapKey({"ctrl"}, "2", keyCode("up", {"cmd"}))
-- remapKey({"ctrl"}, "3", keyCode("down", {"cmd"}))
-- remapKey({'ctrl'}, 'v', keyCode('pagedown'))
-- remapKey({'alt'}, 'v', keyCode('pageup'))
--
-- remapKey({"ctrl"}, "a", keyCode("left", {"cmd"}))
-- remapKey({"ctrl"}, "e", keyCode("right", {"cmd"}))
--
-- -- Cursor with shift
remapKey({"ctrl", "cmd"}, "e", keyCode("right", {"ctrl"}))
remapKey({"ctrl", "cmd"}, "a", keyCode("left", {"ctrl"}))
--
-- -- Around Exposé
remapKey({"ctrl", "cmd"}, "p", keyCode("up", {"ctrl"}))
remapKey({"ctrl", "cmd"}, "n", keyCode("down", {"ctrl"}))
--
-- -- Enter
remapKey({"ctrl"}, "m", keyCode("return"))
remapKey({"ctrl", "option"}, "m", keyCode("return", {"option"}))
--
-- -- Cut/Copy/Yank
-- remapKey({"ctrl"}, "w", keyCode("x", {"cmd"}))
-- remapKey({"ctrl"}, "y", keyCode("v", {"cmd"}))
--
-- -- Delete
-- remapKey({'ctrl'}, 'h', keyCode('delete')) -- backspace
-- remapKey({'ctrl'}, 'd', keyCode('forwarddelete')) -- delete
--
-- -- Escape
-- remapKey({"ctrl"}, "g", keyCode("escape"))
--
-- -- Undo
remapKey({'ctrl'}, "/", keyCode("z", {'cmd'}))

-- open Terminal
hs.hotkey.bind({'cmd', 'ctrl'}, 't', function()
  hs.execute("open -a iTerm; osascript -e 'tell application \"System Events\" to key code 102'")
end)


local VK_G = 0x5
local VK_ESC = 0x35

-- Secret key codes not included in hs.keycodes.map
local VK_QUOTE = 0x27
local VK_SEMICOLON = 0x29

-- --local log = hs.logger.new("keyhook","debug")
function flagsMatches(flags, modifiers)
    local set = {}
    for _, k in ipairs(modifiers) do set[string.lower(k)] = true end
    for _, k in ipairs({"fn", "cmd", "ctrl", "alt", "shift"}) do
        if set[k] ~= flags[k] then return false end
    end
    return true
end

myKeyboardFilter = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, function(event)
    local c = event:getKeyCode()
    local f = event:getFlags()
    if c == VK_SEMICOLON then
        -- swap semicolon and colon
        if flagsMatches(f, {"shift"}) then
            event:setFlags({})
        elseif flagsMatches(f, {}) then
            event:setFlags({shift=true})
        end
    elseif c == VK_QUOTE then
        -- swap single quote and doble quote
        if flagsMatches(f, {"shift"}) then
            event:setFlags({})
        elseif flagsMatches(f, {}) then
            event:setFlags({shift=true})
        end
    elseif c == VK_G then
        -- ctrl+g => Esc
        if flagsMatches(f, {"ctrl"}) then
            event:setKeyCode(VK_ESC)
            event:setFlags({})
        end
    end
end)
myKeyboardFilter:start()

