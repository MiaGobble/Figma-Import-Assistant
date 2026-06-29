local Toolbar = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function Toolbar:Init(Scope, Properties)

end

function Toolbar:Construct(Scope, Properties)
    return Plugin:CreateToolbar(Properties.Name or "")
end

AssertStructure(Plugin, Seam)

return Seam.Component(Toolbar)