local AppImportInterpreter = {}

-- Constants
local TAG_ACTIONS = {
    ["GROUP"] = "BreakAfter",
    ["IGNORE"] = "Continue",
    ["TEXT"] = "ClassTextLabel",
    ["TYPE_IMAGE"] = "ClassImageLabel",
    ["TYPE_BUTTON"] = "ClassImageButton",
    ["TYPE_FRAME"] = "ClassFrame",
    ["TYPE_SCROLLING_FRAME"] = "ClassScrollingFrame",
}

-- Services
local HttpService = game:GetService("HttpService")

local function ResolveMode(mode)
    if type(mode) ~= "string" then
        return "classic"
    end

    mode = string.lower(mode)

    if mode == "opportunistic" then
        return "opportunistic"
    end

    return "classic"
end

local function InferModeFromPayload(payload)
    if type(payload) ~= "table" then
        return nil
    end

    local Meta = payload.meta or payload.Meta

    if type(Meta) == "table" then
        local MetaMode = Meta.mode or Meta.Mode

        if type(MetaMode) == "string" then
            return MetaMode
        end
    end

    local Nodes = payload.nodes or payload.Nodes or payload.Root

    if type(Nodes) == "table" then
        local FirstNode = Nodes[1]

        if type(FirstNode) == "table" and type(FirstNode.mode) == "string" then
            return FirstNode.mode
        end
    elseif type(payload[1]) == "table" and type(payload[1].mode) == "string" then
        return payload[1].mode
    end

    return nil
end

local function GetOpacityAndColor(child)
    local Opacity = child.opacity or 1
    local Color = Color3.fromRGB(255, 255, 255)

    if child.fills then
        Opacity = 0

        for _, Fill in ipairs(child.fills) do
            if Fill.type == "SOLID" then
                Color = Color3.fromRGB(Fill.color.r * 255, Fill.color.g * 255, Fill.color.b * 255)
            end

            Opacity += Fill.opacity
        end
    end

    return Opacity, Color
end

local function GetStrokeColor(child)
    local Strokes = child.strokes
    local StrokeColor = Color3.fromRGB(255, 255, 255)

    if type(Strokes) ~= "table" then
        return StrokeColor
    end

    for _, Stroke in ipairs(Strokes) do
        if Stroke.type == "SOLID" and Stroke.color then
            StrokeColor = Color3.fromRGB(Stroke.color.r * 255, Stroke.color.g * 255, Stroke.color.b * 255)
            break
        end
    end

    return StrokeColor
end

local function CompileShadowData(child)
    local ShadowData = {}

    if child.effects then
        for _, Effect in ipairs(child.effects) do
            if Effect.type == "DROP_SHADOW" then
                if Effect.visible == false then
                    continue
                end

                table.insert(ShadowData, {
                    Offset = Vector2.new(Effect.offset.x, Effect.offset.y),
                    Radius = Effect.radius,
                    Spread = Effect.spread,
                })
            end
        end
    end

    local MaxOffset = Vector2.new(0, 0)
    local MaxRadius = 0
    local MaxSpread = 0

    for _, Shadow in ipairs(ShadowData) do
        if Shadow.Offset.Magnitude > MaxOffset.Magnitude then
            MaxOffset = Shadow.Offset
        end

        if Shadow.Radius > MaxRadius then
            MaxRadius = Shadow.Radius
        end

        if Shadow.Spread > MaxSpread then
            MaxSpread = Shadow.Spread
        end
    end

    return {
        Offset = MaxOffset,
        Radius = MaxRadius,
        Spread = MaxSpread,
    }
end

local function ReadRecursive(parentTable, mode)
    local ChildTable = {
        Root = {},
    }

    for Index, Child in ipairs(parentTable) do
        local Opacity, Color = GetOpacityAndColor(Child)
        local StrokeColor = GetStrokeColor(Child)

        local TextData = Child.text or {}
        local FontData = TextData.fontName or Child.fontName or {}
        local TextFontFamily = nil
        local TextFontStyle = nil

        if type(FontData) == "table" then
            TextFontFamily = FontData.family
            TextFontStyle = FontData.style
        elseif type(FontData) == "string" then
            TextFontFamily = FontData
            TextFontStyle = "Regular"
        end

        local AutoLayoutData = Child.autoLayout or {}
        local LayoutMode = AutoLayoutData.layoutMode or Child.layoutMode
        local LayoutWrap = AutoLayoutData.layoutWrap or Child.layoutWrap
        local ItemSpacing = AutoLayoutData.itemSpacing or Child.itemSpacing
        local PaddingLeft = AutoLayoutData.paddingLeft or Child.paddingLeft
        local PaddingRight = AutoLayoutData.paddingRight or Child.paddingRight
        local PaddingTop = AutoLayoutData.paddingTop or Child.paddingTop
        local PaddingBottom = AutoLayoutData.paddingBottom or Child.paddingBottom
        local PrimaryAxisSizingMode = AutoLayoutData.primaryAxisSizingMode
        local CounterAxisSizingMode = AutoLayoutData.counterAxisSizingMode
        local PrimaryAxisAlignItems = AutoLayoutData.primaryAxisAlignItems
        local CounterAxisAlignItems = AutoLayoutData.counterAxisAlignItems

        local IsText = Child.type == "TEXT"
        local IsGroup = Child.type == "GROUP"
        local HasAutoLayout = LayoutMode ~= nil and LayoutMode ~= "NONE"
        local HasStroke = Child.strokeWeight ~= nil and Child.strokeWeight > 0

        local DefaultType = "ImageLabel"

        if mode ~= "opportunistic" and IsGroup then
            DefaultType = "Frame"
        end

        if IsGroup then
            Opacity = 0
            HasStroke = false
        end

        local Interpretation = {
            Size = {
                X = Child.width,
                Y = Child.height
            },
    
            Position = {
                X = Child.x,
                Y = Child.y,
            },

            Rotation = -(Child.rotation or 0),

            LayoutOrder = Index,
    
            AnchorPoint = {
                X = 0,
                Y = 0
            },
    
            Name = Child.name or "AUTOIMPORT",
            Image = "",
            Stroke = Child.strokeWeight or 0,
            Oblique = 0,
            IsGroup = IsGroup,
            IsText = IsText,
            HasAutoLayout = HasAutoLayout,
            HasStroke = HasStroke,
            RawType = Child.type,
            Text = TextData.characters or Child.characters or "",
            TextSize = TextData.fontSize or Child.fontSize or 14,
            TextColor = Color,
            TextFontFamily = TextFontFamily,
            TextFontStyle = TextFontStyle,
            StrokeColor = StrokeColor,
            LayoutMode = LayoutMode,
            LayoutWrap = LayoutWrap,
            LayoutPadding = PaddingLeft or 0,
            LayoutPaddingLeft = PaddingLeft or 0,
            LayoutPaddingRight = PaddingRight or 0,
            LayoutPaddingTop = PaddingTop or 0,
            LayoutPaddingBottom = PaddingBottom or 0,
            LayoutSpacing = ItemSpacing or 0,
            PrimaryAxisSizingMode = PrimaryAxisSizingMode,
            CounterAxisSizingMode = CounterAxisSizingMode,
            PrimaryAxisAlignItems = PrimaryAxisAlignItems,
            CounterAxisAlignItems = CounterAxisAlignItems,
            Settings = {
                IsAspectRatioConstrained = true,
                ClipDescendants = true,
            },
            Opacity = Opacity or 1,
            Color = Color or Color3.fromRGB(255, 255, 255),
            CornerRadius = Child.cornerRadius or 0,
            Shadow = CompileShadowData(Child),
    
            -- Unique data from import
            Type = DefaultType
        }

        if Child.children then
            Interpretation.Children = ReadRecursive(Child.children, mode)
        else
            Interpretation.Children = {}
        end
    
        table.insert(ChildTable.Root, Interpretation)
    end

    return ChildTable
end

function AppImportInterpreter:InterpretJSONData(jsonData : string, mode : string)
    local Data = HttpService:JSONDecode(jsonData)
    local PayloadMode = InferModeFromPayload(Data)
    local ResolvedMode = ResolveMode(PayloadMode or mode)

    local Nodes = Data

    if type(Data) == "table" then
        Nodes = Data.nodes or Data.Nodes or Data.Root or Data
    end

    local Interpretation = ReadRecursive(Nodes, ResolvedMode)
    Interpretation.Mode = ResolvedMode

    return Interpretation
end

function AppImportInterpreter:GetActionsFromName(name : string)
    local RawTags = string.split(name, "@")
    local BaseName = RawTags[1]
    local Actions = {}

    for Index, Tag in ipairs(RawTags) do
        if Index > 1 and TAG_ACTIONS[Tag] then
            Actions[TAG_ACTIONS[Tag]] = true
        end
    end

    return Actions, BaseName
end

return AppImportInterpreter