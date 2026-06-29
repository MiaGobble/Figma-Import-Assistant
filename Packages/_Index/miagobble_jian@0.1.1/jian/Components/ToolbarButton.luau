local ToolbarButton = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function ToolbarButton:Init(Scope, Properties)

end

function ToolbarButton:Construct(Scope, Properties)
    local Button : PluginToolbarButton = Properties.Toolbar:CreateButton(Properties.Name, Properties.ToolTip, Properties.Image)

    if Properties.Active ~= nil then
        if Seam.IsState(Properties.Active) then
            Button:SetActive(Properties.Active.Value)

            Seam.OnChanged(Properties.Active, function()
                Button:SetActive(Properties.Active.Value)
            end)
        else
            Button:SetActive(Properties.Active)
        end
    end

    return Scope:New(Button, StripProps(Properties, {"Toolbar", "Name", "ToolTip", "Image", "Active"}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(ToolbarButton)