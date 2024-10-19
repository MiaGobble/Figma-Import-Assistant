local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Fusion = require(Packages.Fusion)
local Value = Fusion.Value
local Computed = Fusion.Computed

return function(MainContentList, IsItemSelected, Inputs, SelectedItem, Data)
    local EnabledValue = Value(Data.DefaultValue)
    local IsEnabled = Computed(function()
        local IsSelected = IsItemSelected:get()

        if not IsSelected then
            return false
        end

        local Selected = SelectedItem:get()

        if not Selected then
            return false
        end

        if Data.Context == "ScreenGui" then
            return Selected:IsA("ScreenGui")
        elseif Data.Context == "Default" then
            return not Selected:IsA("ScreenGui")
        end
    end)

    local This = Component "Checkbox" {
        Enabled = IsEnabled,
        Visible = IsEnabled,
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