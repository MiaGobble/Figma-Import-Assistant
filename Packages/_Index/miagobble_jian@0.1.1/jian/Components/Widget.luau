local Widget = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function Widget:Init(Scope, Properties)
    self.DockWidgetInfoArray = {
        Properties.InitialDockState or Enum.InitialDockState.Float,
        Properties.InitialEnabled == true,
        Properties.OverridePreviousState == false,
        Properties.DefaultWidth or 200,
        Properties.DefaultHeight or 300,
        Properties.MinimumWidth or 150,
        Properties.MinimumHeight or 150,
    }
end

function Widget:Construct(Scope, Properties)
    local WidgetInfo = DockWidgetPluginGuiInfo.new(unpack(self.DockWidgetInfoArray))
    local WidgetObject = Plugin:CreateDockWidgetPluginGuiAsync(Properties.WidgetId or "", WidgetInfo)
    WidgetObject.Title = Properties.Title or Properties.WidgetId or ""

    return WidgetObject
end

AssertStructure(Plugin, Seam)

return Seam.Component(Widget)