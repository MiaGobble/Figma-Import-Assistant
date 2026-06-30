local Creator = {}

-- Constants
local SIZE_DERITIVATIVE_REF = Vector2.new(1920, 1080)
local FONT_FAMILY_MAP = {
    fredokaone = "FredokaOne",
    gotham = "Gotham",
    arial = "Arial",
    sourcesans = "SourceSansPro",
    sourcesanspro = "SourceSansPro",
    buildersans = "BuilderSans",
    inter = "BuilderSans",
    roboto = "Roboto",
    robotomono = "RobotoMono",
    nunito = "Nunito",
    oswald = "Oswald",
    ubuntu = "Ubuntu",
    bangers = "Bangers",
    cartoon = "Cartoon",
    code = "Code",
    fantasy = "Fantasy",
    highway = "Highway",
    legacy = "Legacy",
    scifi = "SciFi",
    kalam = "Kalam",
    josefinsans = "JosefinSans",
    indiflower = "IndieFlower",
    titilliumweb = "TitilliumWeb",
}

-- Imports
local Applicator = require(script.Parent.Applicator)
local AppImportInterpreter = require(script.Parent.AppImportInterpreter)

local function InterpretActions(name : string)
    local Actions, NewName = AppImportInterpreter:GetActionsFromName(name)

    return Actions, NewName
end

local function GetGuiSizeDerivative(gui : ScreenGui)
    local Size = gui:GetAttribute("FigmaSize") or SIZE_DERITIVATIVE_REF
    local Magnitude = (Size / SIZE_DERITIVATIVE_REF).Magnitude

    return Magnitude
end

local function Clamp(value : number, minimum : number, maximum : number)
    return math.max(minimum, math.min(maximum, value))
end

local function ToScaleFromPixels(pixels : number, axisSize : number)
    local SafeAxis = tonumber(axisSize) or 0

    if SafeAxis <= 0 then
        return 0
    end

    return Clamp((tonumber(pixels) or 0) / SafeAxis, 0, 1)
end

local function ToScaledStrokeThickness(strokePixels : number, sizeX : number, sizeY : number, gui : ScreenGui)
    local ViewportSize = gui:GetAttribute("FigmaSize") or SIZE_DERITIVATIVE_REF
    local ViewportMinAxis = math.min(ViewportSize.X, ViewportSize.Y)
    local ElementMinAxis = math.min(tonumber(sizeX) or 0, tonumber(sizeY) or 0)
    local StrokePixels = tonumber(strokePixels) or 0

    if ViewportMinAxis <= 0 then
        return 0.006
    end

    if ElementMinAxis <= 0 then
        local FallbackScale = StrokePixels / ViewportMinAxis
        return Clamp(FallbackScale * 2.6, 0.0011, 0.035)
    end

    -- Blend element-relative and viewport-relative stroke scales so thin/small and large
    -- elements both stay visually closer to expected thickness.
    local RelativeToElement = StrokePixels / ElementMinAxis
    local RelativeToViewport = StrokePixels / ViewportMinAxis
    local HybridScale = (RelativeToElement * 0.75) + (RelativeToViewport * 0.25)

    return Clamp(HybridScale * 2.4, 0.0011, 0.035)
end

local function ResolveFontFromFigma(family)
    local FamilyName = tostring(family or "")
    local NormalizedFamilyName = string.lower(FamilyName):gsub("[^%w]", "")
    local MappedFamily = FONT_FAMILY_MAP[NormalizedFamilyName] or FamilyName

    local Success, FontFace = pcall(Font.fromName, MappedFamily)

    if Success and FontFace then
        return FontFace
    end

    local BuilderSansSuccess, BuilderSans = pcall(Font.fromName, "BuilderSans")

    if BuilderSansSuccess and BuilderSans then
        return BuilderSans
    end

    return nil
end

local function ApplyImportedTextProperties(object : Instance, child : {}, gui : ScreenGui)
    local RespectText = gui:GetAttribute("FigmaSetting_ImportTextAsText") ~= false
    local ScaleText = gui:GetAttribute("FigmaSetting_ScaleText") ~= false

    if not RespectText then
        return
    end

    if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then
        return
    end

    object.Text = child.Text or object.Text
    local BaseTextSize = tonumber(child.TextSize) or object.TextSize
    object.TextSize = BaseTextSize
    object.TextColor3 = child.TextColor or object.TextColor3

    local ResolvedFont = ResolveFontFromFigma(child.TextFontFamily)
    if ResolvedFont then
        object.FontFace = ResolvedFont
    end

    local ExistingPadding = object:FindFirstChild("FigmaTextPadding")

    if ScaleText then
        object.TextScaled = true

        if not ExistingPadding then
            ExistingPadding = Instance.new("UIPadding")
            ExistingPadding.Name = "FigmaTextPadding"
            ExistingPadding.Parent = object
        end

        local ElementHeight = tonumber(child.Size and child.Size.Y) or 0
        local TargetTextHeight = tonumber(child.TextSize) or 0

        -- Keep text visually close to the exported size without over-shrinking TextScaled labels.
        local VerticalPaddingScale = 0
        if ElementHeight > 0 and TargetTextHeight > 0 then
            local UnusedSpaceRatio = Clamp(1 - (TargetTextHeight / ElementHeight), 0, 1)
            VerticalPaddingScale = Clamp(UnusedSpaceRatio * 0.1, 0, 0.04)
        end

        local Padding = UDim.new(VerticalPaddingScale, 0)
        ExistingPadding.PaddingTop = Padding
        ExistingPadding.PaddingBottom = Padding
        ExistingPadding.PaddingLeft = UDim.new(0, 0)
        ExistingPadding.PaddingRight = UDim.new(0, 0)
    else
        object.TextScaled = false

        if ExistingPadding and ExistingPadding:IsA("UIPadding") then
            ExistingPadding:Destroy()
        end
    end
end

local function IsOpportunisticMode(mode : string)
    return string.lower(mode or "classic") == "opportunistic"
end

local function ApplyOpportunisticEnhancements(object : Instance, child : {}, gui : ScreenGui)
    local RespectProperties = gui:GetAttribute("FigmaSetting_ApplyBackgroundColor") ~= false
    local RespectStroke = gui:GetAttribute("FigmaSetting_ImportStrokesAsUIStroke") ~= false
    local RespectAutoLayout = gui:GetAttribute("FigmaSetting_ApplyAutoLayout") ~= false

    if object:IsA("TextLabel") then
        object.BackgroundTransparency = 1
    end

    if object:IsA("Frame") and RespectProperties then
        object.BackgroundTransparency = 1 - (child.Opacity or 1)
        object.BorderSizePixel = 0
        object.BackgroundColor3 = child.Color or Color3.fromRGB(255, 255, 255)
    end

    if object:IsA("GuiObject") then
        local ExistingStroke = object:FindFirstChildOfClass("UIStroke")
        local IsImageClass = object:IsA("ImageLabel") or object:IsA("ImageButton")

        if IsImageClass then
            if ExistingStroke then
                ExistingStroke:Destroy()
            end
        elseif child.HasStroke and RespectStroke then
            if not ExistingStroke then
                ExistingStroke = Instance.new("UIStroke")
                ExistingStroke.Parent = object
            end

            ExistingStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
            ExistingStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
            ExistingStroke.Thickness = ToScaledStrokeThickness(
                tonumber(child.Stroke) or 1,
                tonumber(child.Size and child.Size.X) or 0,
                tonumber(child.Size and child.Size.Y) or 0,
                gui
            )
            ExistingStroke.Color = child.StrokeColor or child.Color or Color3.fromRGB(255, 255, 255)
        elseif ExistingStroke then
            ExistingStroke:Destroy()
        end
    end

    if child.HasAutoLayout and RespectAutoLayout and object:IsA("GuiObject") then
        local ExistingLayout = object:FindFirstChildOfClass("UIListLayout")

        if not ExistingLayout then
            ExistingLayout = Instance.new("UIListLayout")
            ExistingLayout.Parent = object
        end

        local IsHorizontal = child.LayoutMode == "HORIZONTAL"
        ExistingLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ExistingLayout.FillDirection = if IsHorizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
        ExistingLayout.Wraps = child.LayoutWrap == "WRAP"
        local ContainerWidth = tonumber(child.Size and child.Size.X) or 0
        local ContainerHeight = tonumber(child.Size and child.Size.Y) or 0
        local LayoutAxisSize = if IsHorizontal then ContainerWidth else ContainerHeight
        ExistingLayout.Padding = UDim.new(ToScaleFromPixels(tonumber(child.LayoutSpacing) or 0, LayoutAxisSize), 0)

        -- Disable flex sizing to avoid unexpected shrinking/growing of auto layout children.
        ExistingLayout.HorizontalFlex = Enum.UIFlexAlignment.None
        ExistingLayout.VerticalFlex = Enum.UIFlexAlignment.None

        local PrimaryAlignment = child.PrimaryAxisAlignItems
        if PrimaryAlignment == "MIN" then
            ExistingLayout.HorizontalAlignment = if IsHorizontal then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Center
            ExistingLayout.VerticalAlignment = if IsHorizontal then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top
        elseif PrimaryAlignment == "CENTER" then
            ExistingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            ExistingLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        elseif PrimaryAlignment == "MAX" then
            ExistingLayout.HorizontalAlignment = if IsHorizontal then Enum.HorizontalAlignment.Right else Enum.HorizontalAlignment.Center
            ExistingLayout.VerticalAlignment = if IsHorizontal then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Bottom
        end

        local CounterAlignment = child.CounterAxisAlignItems
        if CounterAlignment == "MIN" then
            if IsHorizontal then
                ExistingLayout.VerticalAlignment = Enum.VerticalAlignment.Top
            else
                ExistingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            end
        elseif CounterAlignment == "CENTER" then
            if IsHorizontal then
                ExistingLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            else
                ExistingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            end
        elseif CounterAlignment == "MAX" then
            if IsHorizontal then
                ExistingLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            else
                ExistingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
            end
        end

        local ExistingPadding = object:FindFirstChildOfClass("UIPadding")

        if not ExistingPadding then
            ExistingPadding = Instance.new("UIPadding")
            ExistingPadding.Parent = object
        end

        local PaddingTop = tonumber(child.LayoutPaddingTop) or tonumber(child.LayoutPadding) or 0
        local PaddingBottom = tonumber(child.LayoutPaddingBottom) or tonumber(child.LayoutPadding) or 0
        local PaddingLeft = tonumber(child.LayoutPaddingLeft) or tonumber(child.LayoutPadding) or 0
        local PaddingRight = tonumber(child.LayoutPaddingRight) or tonumber(child.LayoutPadding) or 0

        ExistingPadding.PaddingTop = UDim.new(ToScaleFromPixels(PaddingTop, ContainerHeight), 0)
        ExistingPadding.PaddingBottom = UDim.new(ToScaleFromPixels(PaddingBottom, ContainerHeight), 0)
        ExistingPadding.PaddingLeft = UDim.new(ToScaleFromPixels(PaddingLeft, ContainerWidth), 0)
        ExistingPadding.PaddingRight = UDim.new(ToScaleFromPixels(PaddingRight, ContainerWidth), 0)

        object:SetAttribute("FigmaAutoLayoutPaddingTop", PaddingTop)
        object:SetAttribute("FigmaAutoLayoutPaddingBottom", PaddingBottom)
        object:SetAttribute("FigmaAutoLayoutPaddingLeft", PaddingLeft)
        object:SetAttribute("FigmaAutoLayoutPaddingRight", PaddingRight)
    end
end

local function CreateRecursive(parent, data : {}, mode : string)
    local Gui = nil

    if parent:IsA("ScreenGui") then
        Gui = parent
    else
        Gui = parent:FindFirstAncestorWhichIsA("ScreenGui")
    end

    for _, Child in ipairs(data.Root) do
        Child.Settings = Child.Settings or {}
        Child.Settings.IsAspectRatioConstrained = Gui:GetAttribute("FigmaSetting_IsAspectRatioConstrained") ~= false
        Child.Settings.ClipDescendants = Child.clipsContent ~= nil and Child.clipsContent or false

        if Gui:GetAttribute("FigmaSetting_DefaultMiddleAnchor") == true then
            Child.AnchorPoint = {
                X = 0.5,
                Y = 0.5,
            }
        end

        local Actions, Name = InterpretActions(Child.Name)

        if Actions.Continue then
            continue
        end

        local Object

        for Action in pairs(Actions) do
            if Action:find("Class") then
                local InstanceType = Action:gsub("Class", "")
                Object = Instance.new(InstanceType)
                break
            end
        end

        if not Object then
            Object = Instance.new(Child.Type)

            if Child.RawType == "GROUP" then
                Object:Destroy()
                Object = Instance.new("Frame")
            end

            if IsOpportunisticMode(mode) and Child.Type == "ImageLabel" then
                if (Child.RawType == "FRAME" or Child.RawType == "GROUP") and Gui:GetAttribute("FigmaSetting_ImportFramesAsFrames") ~= false then
                    Object:Destroy()
                    Object = Instance.new("Frame")
                elseif Child.IsText and Gui:GetAttribute("FigmaSetting_ImportTextAsText") ~= false then
                    Object:Destroy()
                    Object = Instance.new("TextLabel")
                end
            end
        end

        Object.ClipsDescendants = if Child.clipsContent ~= nil then Child.clipsContent else false

        if IsOpportunisticMode(mode) and Object:IsA("Frame") and Gui:GetAttribute("FigmaSetting_RespectAutoImportFrameOpacity") then
            Object.BackgroundTransparency = 1 - Child.Opacity
            Object.BorderSizePixel = 0
            Object.BackgroundColor3 = Child.Color
        else
            Object.BackgroundTransparency = 1
        end

        if Child.CornerRadius > 0 and Gui:GetAttribute("FigmaSetting_RespectAutoImportCornerRadius") then
            local CornerRadius = Instance.new("UICorner")
            CornerRadius.Parent = Object

            local MinAxis = math.min(tonumber(Child.Size and Child.Size.X) or 0, tonumber(Child.Size and Child.Size.Y) or 0)
            local RadiusScale = ToScaleFromPixels(Child.CornerRadius * GetGuiSizeDerivative(Gui), MinAxis)
            CornerRadius.CornerRadius = UDim.new(RadiusScale, 0)
        end
        
        Object.Parent = parent
        Object:SetAttribute("IsFigmaImportGroup", Child.IsGroup)
        Child.Name = Name

        Applicator:ApplyChangesFromData(Object, Child)
        ApplyImportedTextProperties(Object, Child, Gui)
        if IsOpportunisticMode(mode) then
            ApplyOpportunisticEnhancements(Object, Child, Gui)
        end

        if not Actions.BreakAfter and Child.Children then
            CreateRecursive(Object, Child.Children, mode)
        end
    end
end

function Creator:CreateFromData(selectedInstance, data : {}, mode : string)
    local ResolvedMode = string.lower(mode or data.Mode or "classic")
    CreateRecursive(selectedInstance, data, ResolvedMode)
end

return Creator