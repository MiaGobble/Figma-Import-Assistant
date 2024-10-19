local AppImportInterpreter = {}

local TAG_ACTIONS = {
    ["GROUP"] = "BreakAfter",
    ["IGNORE"] = "Continue",
    ["TYPE_IMAGE"] = "ClassImageLabel",
    ["TYPE_BUTTON"] = "ClassImageButton",
    ["TYPE_FRAME"] = "ClassFrame",
    ["TYPE_SCROLLING_FRAME"] = "ClassScrollingFrame",
}

local HttpService = game:GetService("HttpService")

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

local function ReadRecursive(ParentTable)
    local ChildTable = {
        Root = {},
    }

    for _, Child in ipairs(ParentTable) do
        local Opacity, Color = GetOpacityAndColor(Child)

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
            Settings = {
                IsAspectRatioConstrained = true,
                ClipDescendants = true,
            },
            Opacity = Opacity or 1,
            Color = Color or Color3.fromRGB(255, 255, 255),
            CornerRadius = Child.cornerRadius or 0,
            Shadow = CompileShadowData(Child),
    
            -- Unique data from import
            Type = if Child.type == "GROUP" then "Frame" elseif Child.opacity == 0 and Child.strokeWeight == 0 then "Frame" else "ImageLabel"
        }

        if Child.children then
            Interpretation.Children = ReadRecursive(Child.children)
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

function AppImportInterpreter:InterpretJSONData(JSONData : string)
    local Data = HttpService:JSONDecode(JSONData)
    local Interpretation = ReadRecursive(Data)

    return Interpretation
end

function AppImportInterpreter:GetActionsFromName(Name : string)
    local RawTags = string.split(Name, "@")
    local Name = RawTags[1]
    local Actions = {}

    for Index, Tag in ipairs(RawTags) do
        if Index > 1 and TAG_ACTIONS[Tag] then
            Actions[TAG_ACTIONS[Tag]] = true
        end
    end

    return Actions, Name
end

return AppImportInterpreter