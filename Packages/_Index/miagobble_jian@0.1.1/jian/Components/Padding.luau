local Padding = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function Padding:Init(Scope, Properties)
    
end

function Padding:Construct(Scope, Properties)
    local UIPadding = Scope:New("UIPadding", {
        PaddingBottom = UDim.new(0, Styles.Padding),
        PaddingTop = UDim.new(0, Styles.Padding),
        PaddingLeft = UDim.new(0, Styles.Padding),
        PaddingRight = UDim.new(0, Styles.Padding),
    })

    return Scope:New(UIPadding, StripProps(Properties, {}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(Padding)