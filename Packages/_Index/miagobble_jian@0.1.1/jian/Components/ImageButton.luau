local ImageButton = {}

-- Services
local Plugin = script:FindFirstAncestorOfClass("Plugin")

-- Imports
local Modules = script.Parent.Parent.Modules
local StripProps = require(Modules.StripProps)
local Styles = require(Modules.Styles)
local AssertStructure = require(Modules.AssertStructure)
local Seam = if Plugin and Plugin:FindFirstChild("Seam", true) then require(Plugin:FindFirstChild("Seam", true)) else nil

function ImageButton:Init(Scope, Properties)
    self.State = Scope:Value("Idle")
end

function ImageButton:Construct(Scope, Properties)
    local Button = Scope:New("ImageButton", {
        Active = Properties.Active,
        Interactable = Properties.Active,
        Size = UDim2.fromOffset(120, 35),
        BorderSizePixel = 0,
        BackgroundTransparency = 0,
        AutoButtonColor = false,
        
        ImageColor3 = Scope:Computed(function(Use)
            if Use(Properties.Active) == false then
                return Styles.TextColorInactive
            else
                return Styles.TextColor
            end
        end),

        BackgroundColor3 = Scope:Spring(Scope:Computed(function(Use)
            local CurrentState = Use(self.State)

            if Use(Properties.Active) == false then
                return Styles.ButtonInactiveColor
            end

            if CurrentState == "Press" then
                return Styles.ButtonPressColor
            elseif CurrentState == "Hover" then
                return Styles.ButtonHoverColor
            else
                return Styles.ButtonDefaultColor
            end
        end), 30, 1),

        [Seam.OnEvent "MouseEnter"] = function()
            self.State.Value = "Hover"
        end,

        [Seam.OnEvent "MouseLeave"] = function()
            self.State.Value = "Idle"
        end,

        [Seam.OnEvent "MouseButton1Down"] = function()
            self.State.Value = "Press"
        end,

        [Seam.OnEvent "MouseButton1Up"] = function()
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
                    if Use(self.State) == "Press" then
                        return Styles.StrokePressColor
                    elseif Use(self.State) == "Hover" then
                        return Styles.StrokeHoverColor
                    else
                        return Styles.StrokeDefaultColor
                    end
                end), 30, 1),
            })
        }
    })

    return Scope:New(Button, StripProps(Properties, {"Active"}))
end

AssertStructure(Plugin, Seam)

return Seam.Component(ImageButton)