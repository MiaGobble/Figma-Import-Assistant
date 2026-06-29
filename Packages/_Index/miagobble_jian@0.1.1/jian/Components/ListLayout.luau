local ListLayout = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function ListLayout:Init(Scope, Properties)
    
end

function ListLayout:Construct(Scope, Properties)
    local UIListLayout = Scope:New("UIListLayout", {
        Padding = UDim.new(0, 15),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    return Scope:New(UIListLayout, StripProps(Properties, {}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(ListLayout)