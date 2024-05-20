local Packages = script.Parent.Parent.Parent.Packages
local Component = require(script.Parent.Parent.Component)
local Fusion = require(Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children

return function(MainContentList)
    local Frame = Component "Background" {
        Size = UDim2.new(1, 0, 0, 30),
        Parent = MainContentList,

        [Children] = {
            New "UIListLayout" {
                Padding = UDim.new(0.05, 0),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
            }
        }
    }

    return Frame
end