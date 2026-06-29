local ListSection = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil
local TextButton = require(script.Parent.TextButton)
local ListLayout = require(script.Parent.ListLayout)

function ListSection:Init(Scope, Properties)
    self.IsOpen = Scope:Value(Properties.OpenByDefault == true)
end

function ListSection:Construct(Scope, Properties)
    local ChildrenFrame = Scope:New("Frame", {
        LayoutOrder = 2,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [Seam.Children] = {
            Scope:New(ListLayout, {}),
            unpack(Properties[Seam.Children]),
        },
    })

    local Button = Scope:New(TextButton, {
        Text = Properties.Text,
        Size = UDim2.new(1, 0, 0, 25),
        LayoutOrder = 1,
        Active = Properties.Active,
        DimFactor = 0.3,

        [Seam.OnEvent "Activated"] = function()
            self.IsOpen.Value = not self.IsOpen.Value
        end,

        [Seam.Children] = {
            Scope:New("ImageLabel", {
                Image = "rbxassetid://103256317191387",
                Size = UDim2.fromScale(0.1, 0.65),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.9, 0.5),

                ImageColor3 = Scope:Computed(function(Use)
                    if Use(Properties.Active) == false then
                        return Styles.TextColorInactive
                    else
                        return Styles.TextColor
                    end
                end),

                Rotation = Scope:Spring(Scope:Computed(function(Use)
                    if Use(self.IsOpen) then
                        return 0
                    else
                        return -90
                    end
                end), 30, 1),

                [Seam.Children] = {
                    Scope:New("UIAspectRatioConstraint", {})
                }
            })
        }
    })

    local Layout = Scope:New(ListLayout, {})

    local ParentFrame = Scope:New("Frame", {
        BackgroundTransparency = 1,
        ClipsDescendants = true,

        Size = Scope:Spring(Scope:Computed(function(Use)
            if Use(self.IsOpen) then
                return UDim2.new(1, 0, 0, Button.AbsoluteSize.Y + ChildrenFrame.AbsoluteSize.Y + Layout.Padding.Offset)
            else
                return UDim2.new(1, 0, 0, Button.AbsoluteSize.Y)
            end
        end), 30, 1),

        [Seam.Children] = {
            Layout,
            Button,
            ChildrenFrame,
        }
    })

    if Seam.IsState(Properties.Active) then
        Seam.OnChanged(Properties.Active, function()
            if not Properties.Active.Value then
                self.IsOpen.Value = false
            end
        end)
    end

    return Scope:New(ParentFrame, StripProps(Properties, {"Text", "Active", "OpenByDefault", Seam.Children}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(ListSection)