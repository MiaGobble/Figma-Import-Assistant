local TextBox = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil
local Text = require(script.Parent.Text)

function TextBox:Init(Scope, Properties)
    self.State = Scope:Value("Idle")
end

function TextBox:Construct(Scope, Properties)
    local Input = Scope:New("TextBox", {
        Active = Properties.Active,
        Interactable = Properties.Active,
        Size = UDim2.fromOffset(120, 35),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        FontFace = Styles.TextFont,
        TextSize = Styles.TextSize,
        Text = "",
        PlaceholderText = "Type here...", 

        TextColor3 = Scope:Computed(function(Use)
            if Use(Properties.Active) == false then
                return Styles.TextColorInactive
            else
                return Styles.TextColor
            end
        end),

        BackgroundColor3 = Scope:Spring(Scope:Computed(function(Use)
            local CurrentState = Use(self.State)

            if Use(Properties.Active) == false then
                return Styles.TextBoxInactiveColor
            end

            if CurrentState == "Focused" then
                return Styles.TextBoxFocusedColor
            else
                return Styles.TextBoxDefaultColor
            end
        end), 30, 1),

        [Seam.OnEvent "Focused"] = function()
            self.State.Value = "Focused"
        end,

        [Seam.OnEvent "FocusLost"] = function()
            self.State.Value = "Idle"
        end,

        [Seam.Children] = {
            Scope:New("UICorner", {
                CornerRadius = UDim.new(0, Styles.CornerRadius)
            }),

            Scope:New("UIStroke", {
                Thickness = Styles.StrokeThickness,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,

                Color = Scope:Spring(Scope:Computed(function(Use)
                    if Use(self.State) == "Focused" then
                        return Styles.StrokePressColor
                    else
                        return Styles.StrokeDefaultColor
                    end
                end), 30, 1),
            })
        }
    })

    if Properties.Title then
        local Title = Scope:New(Text, {
            Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 12),
            Position = UDim2.fromOffset(0, -2),
            AnchorPoint = Vector2.new(0, 1),
            TextSize = Styles.TextBoxTitleTextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = Properties.Title,
            Parent = Input,
        })
    end

    return Scope:New(Input, StripProps(Properties, {"Title", "Active"}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(TextBox)