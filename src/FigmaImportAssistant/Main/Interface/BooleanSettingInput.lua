-- Imports
local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Fusion = require(Packages.Fusion)
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(mainContentList, isItemSelected, inputs, selectedItem, data)
    local EnabledValue = Value(data.DefaultValue)

    local IsEnabled = Computed(function()
        local IsSelected = isItemSelected:get()

        if not IsSelected then
            return false
        end

        local Selected = selectedItem:get()

        if not Selected then
            return false
        end

        if data.Context == "ScreenGui" then
            return Selected:IsA("ScreenGui")
        elseif data.Context == "Default" then
            return not Selected:IsA("ScreenGui")
        end

        return false
    end)

    local This = Component "Checkbox" {
        Enabled = IsEnabled,
        Visible = IsEnabled,
        Name = `Setting_{data.Name}`,
        Text = data.Text,
        LayoutOrder = 6,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = mainContentList,
        Value = EnabledValue,
    }

    inputs[`Setting_{data.Name}`] = {EnabledValue, data.DefaultValue}

    return This
end