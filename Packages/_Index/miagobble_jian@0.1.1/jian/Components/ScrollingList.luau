local ScrollingList = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil
local ListLayout = require(script.Parent.ListLayout)

function ScrollingList:Init(Scope, Properties)
    
end

function ScrollingList:Construct(Scope, Properties)
    local Frame = Scope:New("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.fromScale(0, 0),
        BorderSizePixel = 0,
        ScrollBarThickness = 5,
        ScrollBarImageColor3 = Color3.fromRGB(99, 99, 99),

        [Seam.Children] = {
            Scope:New(ListLayout, {})
        }
    })

    return Scope:New(Frame, StripProps(Properties, {}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(ScrollingList)