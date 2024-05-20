local Keybind = {}
Keybind.__index = Keybind

local UserInputService = game:GetService("UserInputService")

local Plugin = script:FindFirstAncestorOfClass("Plugin") :: Plugin

function Keybind.new(Name, BindKeycodes)
    local self = setmetatable({}, Keybind)

    self.Callback = nil
    self.Name = Name
    self.BindKeycodes = BindKeycodes
    self.PressedKeys = {}
    self.Connections = {}
    self.Action = nil

    return self
end

function Keybind:SetCallback(... : () -> boolean)
    self.Callback = ...
end

function Keybind:DoesMatchSearchTerm(SearchTerm : string)
    return if self.Name:lower():gsub(" ", ""):find(SearchTerm:lower():gsub(" ", "")) then true else false
end

function Keybind:Run()
    if self.Callback then
        return self.Callback()
    else
        return (function()
            return false
        end)()
    end
end

function Keybind:Update()
    for _, Keycode in ipairs(self.BindKeycodes) do
        if not self.PressedKeys[Keycode] then
            return
        end
    end
    
    self:Run()
end

function Keybind:Bind()
    -- for _, Keycode in ipairs(self.BindKeycodes) do
    --     print(Keycode)
    --     self.Connections[#self.Connections + 1] = UserInputService.InputBegan:Connect(function(Input)
    --         if Input.KeyCode == Keycode then
    --             self.PressedKeys[Keycode] = true
    --             self:Update()
    --         end
    --     end)

    --     self.Connections[#self.Connections + 1] = UserInputService.InputEnded:Connect(function(Input)
    --         if Input.KeyCode == Keycode then
    --             self.PressedKeys[Keycode] = false
    --         end
    --     end)
    -- end

    self.Action = Plugin:CreatePluginAction(self.Name, self.Name, self.Name, "", true)
    
    self.Action.Triggered:Connect(function()
        self:Run()
    end)
end

function Keybind:Unbind()
    for _, Connection in ipairs(self.Connections) do
        table.remove(self.Connections, table.find(self.Connections, Connection))
        Connection:Disconnect()
    end

    if self.Action then
        self.Action:Destroy()
    end
end

function Keybind:Destroy()
    self:Unbind()
end

return Keybind