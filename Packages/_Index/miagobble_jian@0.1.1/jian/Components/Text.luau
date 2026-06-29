local Text = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function Text:Init(Scope, Properties)
    
end

function Text:Construct(Scope, Properties)
    local TextLabel = Scope:New("TextLabel", {
        Text = "Label",
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        FontFace = Styles.TextFont,
        TextSize = Styles.TextSize,

        TextColor3 = Scope:Computed(function(Use)
            if Use(Properties.Active) == false then
                return Styles.TextColorInactive
            else
                return Styles.TextColor
            end
        end),
    })

    return Scope:New(TextLabel, StripProps(Properties, {"Active"}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(Text)