local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Fusion = require(Packages.Fusion)
local Value = Fusion.Value

return function(MainContentList, IsItemSelected, Inputs, SelectedItem, Data)
    local EnabledValue = Value(Data.DefaultValue)

    local This = Component "Checkbox" {
        Enabled = IsItemSelected,
        Name = `Setting_{Data.Name}`,
        Text = Data.Text,
        LayoutOrder = 6,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainContentList,
        Value = EnabledValue,
    }

    Inputs[`Setting_{Data.Name}`] = {EnabledValue, Data.DefaultValue}

    return This
end