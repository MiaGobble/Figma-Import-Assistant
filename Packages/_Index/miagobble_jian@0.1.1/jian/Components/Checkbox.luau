local Checkbox = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil
local ImageButton = require(script.Parent.ImageButton)
local ListLayout = require(script.Parent.ListLayout)
local Text = require(script.Parent.Text)

function Checkbox:Init(Scope, Properties)
    self.Value = Properties.Value or Scope:Value(false)
end

function Checkbox:Construct(Scope, Properties)
    local Frame = Scope:New("Frame", {
        Size = UDim2.fromOffset(120, 20),
        BackgroundTransparency = 1,

        [Seam.Children] = {
            Scope:New(ListLayout, {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 8),
            }),

            Scope:New(ImageButton, {
                Active = Properties.Active,
                Size = UDim2.fromScale(0.2, 1),

                Image = Scope:Computed(function(Use)
                    if Use(self.Value) then
                        return "rbxassetid://138861967300749"
                    else
                        return ""
                    end
                end),

                [Seam.OnEvent "Activated"] = function()
                    self.Value.Value = not self.Value.Value
                end,

                [Seam.Children] = {
                    Scope:New("UIAspectRatioConstraint", {})
                }
            }),

            Scope:New(Text, {
                Size = UDim2.fromScale(0.8, 1),
                Text = Properties.Title or "",
                TextXAlignment = Enum.TextXAlignment.Left,
            })
        }
    })

    return Scope:New(Frame, StripProps(Properties, {"Active", "Title", "Value"}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(Checkbox)