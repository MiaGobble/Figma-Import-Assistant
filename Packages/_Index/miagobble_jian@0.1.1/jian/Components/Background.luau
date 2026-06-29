local Background = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function Background:Init(Scope, Properties)
    
end

function Background:Construct(Scope, Properties)
    local Frame = Scope:New("Frame", {
        BackgroundColor3 = Styles.BackgroundColor,
        Size = UDim2.fromScale(1, 1),
        BorderSizePixel = 0,
        ZIndex = 0,
    })

    return Scope:New(Frame, StripProps(Properties, {}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(Background)