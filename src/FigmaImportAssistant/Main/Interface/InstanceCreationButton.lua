-- Services
local SelectionService = game:GetService("Selection")

-- Imports
local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Keybinds = require(script.Parent.Keybinds)
local Utility = require(script.Parent.Parent.Utility)
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local OnEvent = Fusion.OnEvent
local Hydrate = Fusion.Hydrate


return function(inputs, mainContentList, selectedItem, isItemSelected, data)
    inputs[`CreateChild{data.ClassName}`] = Component "Button" {
        Enabled = isItemSelected,
        Name = `CreateChild{data.ClassName}`,
        Text = `Create Child {data.ClassName}`,
        LayoutOrder = 6,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = mainContentList,

        [OnEvent "Activated"] = Keybinds:AddKeybind(`c{data.ClassName}`, {}, function()
            if selectedItem:get() then
                Utility.CreateUndoMarkerStart()

                SelectionService:Set({
                    Hydrate(New(data.ClassName)({
                        Name = data.ClassName,
                        Parent = selectedItem:get()
                    }))(data.Properties)
                })

                Utility.CreateUndoMarkerEnd()
            end
        end).Callback
    }

    return inputs[`CreateChild{data.ClassName}`]
end