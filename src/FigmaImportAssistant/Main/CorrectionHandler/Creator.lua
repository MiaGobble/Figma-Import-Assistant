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

    if not RespectText then
        return
    end

    if not (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) then
        return
    end

    object.Text = child.Text or object.Text
    object.TextSize = tonumber(child.TextSize) or object.TextSize
    object.TextColor3 = child.TextColor or object.TextColor3

    local ResolvedFont = ResolveFontFromFigma(child.TextFontFamily)
    if ResolvedFont then
        object.FontFace = ResolvedFont
    end
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
            ExistingStroke.Thickness = tonumber(child.Stroke) or 1
            ExistingStroke.Color = child.StrokeColor or child.Color or Color3.fromRGB(255, 255, 255)
        elseif ExistingStroke then
            ExistingStroke:Destroy()
        end
    end

    if child.HasAutoLayout and RespectAutoLayout and (object:IsA("Frame") or object:IsA("ScrollingFrame")) then
        local ExistingLayout = object:FindFirstChildOfClass("UIListLayout")

        if not ExistingLayout then
            ExistingLayout = Instance.new("UIListLayout")
            ExistingLayout.Parent = object
        end

        local IsHorizontal = child.LayoutMode == "HORIZONTAL"
        ExistingLayout.FillDirection = if IsHorizontal then Enum.FillDirection.Horizontal else Enum.FillDirection.Vertical
        ExistingLayout.Wraps = child.LayoutWrap == "WRAP"
        ExistingLayout.Padding = UDim.new(0, tonumber(child.LayoutSpacing) or 0)

        -- Flex behavior derived from Figma sizing modes.
        ExistingLayout.HorizontalFlex = Enum.UIFlexAlignment.None
        ExistingLayout.VerticalFlex = Enum.UIFlexAlignment.None

        local PrimarySizing = child.PrimaryAxisSizingMode
        local CounterSizing = child.CounterAxisSizingMode

        if PrimarySizing == "AUTO" then
            if IsHorizontal then
                ExistingLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
            else
                ExistingLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
            end
        end

        if CounterSizing == "AUTO" then
            if IsHorizontal then
                ExistingLayout.VerticalFlex = Enum.UIFlexAlignment.Fill
            else
                ExistingLayout.HorizontalFlex = Enum.UIFlexAlignment.Fill
            end
        end

        if child.PrimaryAxisAlignItems == "SPACE_BETWEEN" then
            if IsHorizontal then
                ExistingLayout.HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween
            else
                ExistingLayout.VerticalFlex = Enum.UIFlexAlignment.SpaceBetween
            end
        end

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

        ExistingPadding.PaddingTop = UDim.new(0, tonumber(child.LayoutPaddingTop) or tonumber(child.LayoutPadding) or 0)
        ExistingPadding.PaddingBottom = UDim.new(0, tonumber(child.LayoutPaddingBottom) or tonumber(child.LayoutPadding) or 0)
        ExistingPadding.PaddingLeft = UDim.new(0, tonumber(child.LayoutPaddingLeft) or tonumber(child.LayoutPadding) or 0)
        ExistingPadding.PaddingRight = UDim.new(0, tonumber(child.LayoutPaddingRight) or tonumber(child.LayoutPadding) or 0)
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

            if mode == "opportunistic" and Child.Type == "ImageLabel" then
                if Child.RawType == "FRAME" and Gui:GetAttribute("FigmaSetting_ImportFramesAsFrames") ~= false then
                    Object:Destroy()
                    Object = Instance.new("Frame")
                elseif Child.IsText and Gui:GetAttribute("FigmaSetting_ImportTextAsText") ~= false then
                    Object:Destroy()
                    Object = Instance.new("TextLabel")
                end
            end
        end

        Object.ClipsDescendants = if Child.clipsContent ~= nil then Child.clipsContent else true

        if mode == "opportunistic" and Object:IsA("Frame") and Gui:GetAttribute("FigmaSetting_RespectAutoImportFrameOpacity") then
            Object.BackgroundTransparency = 1 - Child.Opacity
            Object.BorderSizePixel = 0
            Object.BackgroundColor3 = Child.Color
        else
            Object.BackgroundTransparency = 1
        end

        if Child.CornerRadius > 0 and Gui:GetAttribute("FigmaSetting_RespectAutoImportCornerRadius") then
            local CornerRadius = Instance.new("UICorner")
            CornerRadius.Parent = Object
            CornerRadius.CornerRadius = UDim.new(0, Child.CornerRadius * GetGuiSizeDerivative(Gui))
        end
        
        Object.Parent = parent
        Object:SetAttribute("IsFigmaImportGroup", Child.IsGroup)
        Child.Name = Name

        Applicator:ApplyChangesFromData(Object, Child)
        ApplyImportedTextProperties(Object, Child, Gui)
        if mode == "opportunistic" then
            ApplyOpportunisticEnhancements(Object, Child, Gui)
        end

        if not Actions.BreakAfter and Child.Children then
            CreateRecursive(Object, Child.Children, mode)
        end
    end
end

function Creator:CreateFromData(selectedInstance, data : {}, mode : string)
    CreateRecursive(selectedInstance, data, string.lower(mode or "classic"))
end

return Creator