local Keybinds = {}

local KeybindClass = require(script.Keybind)
local ImportedBinds = {}

function Keybinds:AddKeybind(Name, BindKeycodes, Callback)
    local NewKeybind = KeybindClass.new(Name, BindKeycodes)

    NewKeybind:SetCallback(Callback)
    NewKeybind:Bind()
    table.insert(ImportedBinds, NewKeybind)

    return NewKeybind
end

function Keybinds:GetKeybindsFromSearch(SearchTerm)
    local Formatted = {}

    for _, Keybind in ipairs(ImportedBinds) do
        if Keybind:DoesMatchSearchTerm(SearchTerm) then
            table.insert(Formatted, Keybind)
        end
    end

    return Formatted
end

return Keybinds