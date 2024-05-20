local SelectionService = game:GetService("Selection")

local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Keybinds = require(script.Parent.Keybinds)
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local Hydrate = Fusion.Hydrate

return function(Inputs, MainContentList, SelectedItem, IsItemSelected, Data)
    Inputs[`CreateChild{Data.ClassName}`] = Component "Button" {
        Enabled = IsItemSelected,
        Name = `CreateChild{Data.ClassName}`,
        Text = `Create Child {Data.ClassName}`,
        LayoutOrder = 6,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainContentList,

        [OnEvent "Activated"] = Keybinds:AddKeybind(`CreateChild{Data.ClassName}`, {}, function()
            if SelectedItem:get() then
                SelectionService:Set({
                    Hydrate(New(Data.ClassName)({
                        Name = Data.ClassName,
                        Parent = SelectedItem:get()
                    }))(Data.Properties)
                })
            end
        end).Callback
    }

    return Inputs[`CreateChild{Data.ClassName}`]
end