local AppImportInterpreter = {}

local TAG_ACTIONS = {
    ["GROUP"] = "BreakAfter",
    ["IGNORE"] = "Continue",
    ["TEXT"] = "ClassTextLabel",
    ["TYPE_IMAGE"] = "ClassImageLabel",
    ["TYPE_BUTTON"] = "ClassImageButton",
    ["TYPE_FRAME"] = "ClassFrame",
    ["TYPE_SCROLLING_FRAME"] = "ClassScrollingFrame",
}

local HttpService = game:GetService("HttpService")

local function ResolveMode(Mode)
    if type(Mode) ~= "string" then
        return "classic"
    end

    Mode = string.lower(Mode)

    if Mode == "opportunistic" then
        return "opportunistic"
    end

    return "classic"
end

local function GetOpacityAndColor(Child)
    local Opacity = Child.opacity or 1
    local Color = Color3.fromRGB(255, 255, 255)

    if Child.fills then
        Opacity = 0

        for _, Fill in ipairs(Child.fills) do
            if Fill.type == "SOLID" then
                Color = Color3.fromRGB(Fill.color.r * 255, Fill.color.g * 255, Fill.color.b * 255)
            end

            Opacity += Fill.opacity
        end
    end

    return Opacity, Color
end

local function GetStrokeColor(Child)
    local Strokes = Child.strokes
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

local function CompileShadowData(Child)
    local ShadowData = {}

    if Child.effects then
        for _, Effect in ipairs(Child.effects) do
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

local function ReadRecursive(ParentTable, Mode)
    local ChildTable = {
        Root = {},
    }

    for _, Child in ipairs(ParentTable) do
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
        local HasAutoLayout = LayoutMode ~= nil and LayoutMode ~= "NONE"
        local HasStroke = Child.strokeWeight ~= nil and Child.strokeWeight > 0

        local DefaultType = "ImageLabel"

        if Mode == "opportunistic" then
            if Child.type == "GROUP" or Child.type == "FRAME" then
                DefaultType = "Frame"
            elseif IsText then
                DefaultType = "TextLabel"
            end
        else
            if Child.type == "GROUP" then
                DefaultType = "Frame"
            end
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
    
            AnchorPoint = {
                X = 0,
                Y = 0
            },
    
            Name = Child.name or "AUTOIMPORT",
            Image = "",
            Stroke = Child.strokeWeight or 0,
            Oblique = 0,
            IsGroup = Child.type == "GROUP",
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
            Interpretation.Children = ReadRecursive(Child.children, Mode)
        else
            Interpretation.Children = {}
        end
    
        table.insert(ChildTable.Root, Interpretation)
    end

    -- if ParentTable.children then
    --     ChildTable.Children = ReadRecursive(ParentTable.children)
    -- end

    return ChildTable
end

function AppImportInterpreter:InterpretJSONData(JSONData : string, Mode : string)
    local Data = HttpService:JSONDecode(JSONData)
    local Interpretation = ReadRecursive(Data, ResolveMode(Mode))

    return Interpretation
end

function AppImportInterpreter:GetActionsFromName(Name : string)
    local RawTags = string.split(Name, "@")
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