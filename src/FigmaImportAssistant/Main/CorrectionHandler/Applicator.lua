local Applicator = {}

-- Imports
local Utility = require(script.Parent.Parent.Utility)
local Packages = script.Parent.Parent.Parent.Packages
local Seam = require(Packages.Seam)

local function GetOffsettedSizeAndPositionFromShadow(shadow)
    local SafeShadow = shadow or {}
    local Offset = SafeShadow.Offset or Vector2.new(0, 0)
    local Radius = SafeShadow.Radius or 0
    local Spread = SafeShadow.Spread or 0
    local OffsettedSize = Vector2.new(Radius, Radius) + Vector2.new(Spread, Spread)

    return OffsettedSize, Offset
end

local function ToNumber(value, fallback)
    local Number = tonumber(value)

    if Number == nil then
        return fallback
    end

    return Number
end

local function EnsureAspectRatioConstraint(selectedInstance : Instance, enabled : boolean, aspectRatio : number)
    local Existing = selectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint")

    if enabled then
        if not Existing then
            Existing = Instance.new("UIAspectRatioConstraint")
            Existing.Parent = selectedInstance
        end

        Existing.AspectRatio = aspectRatio
    elseif Existing then
        Existing:Destroy()
    end
end

local function GetContextualParentSizeForChild(selectedInstance : Instance)
    local Parent = selectedInstance.Parent
    local ParentSize = Utility.GetParentProperties(Parent)

    if not Parent or not Parent:IsA("GuiObject") then
        return ParentSize
    end

    if not Parent:FindFirstChildOfClass("UIListLayout") then
        return ParentSize
    end

    local PaddingLeft = tonumber(Parent:GetAttribute("FigmaAutoLayoutPaddingLeft")) or 0
    local PaddingRight = tonumber(Parent:GetAttribute("FigmaAutoLayoutPaddingRight")) or 0
    local PaddingTop = tonumber(Parent:GetAttribute("FigmaAutoLayoutPaddingTop")) or 0
    local PaddingBottom = tonumber(Parent:GetAttribute("FigmaAutoLayoutPaddingBottom")) or 0

    return Vector2.new(
        math.max(1, ParentSize.X - PaddingLeft - PaddingRight),
        math.max(1, ParentSize.Y - PaddingTop - PaddingBottom)
    )
end

function Applicator:ApplyChangesFromData(selectedInstance : Instance, data : {[string] : any})
    if not selectedInstance then
        return
    end

    local Size = Vector2.new(
        ToNumber(data.Size and data.Size.X, selectedInstance:GetAttribute("FigmaSize") and selectedInstance:GetAttribute("FigmaSize").X or 100),
        ToNumber(data.Size and data.Size.Y, selectedInstance:GetAttribute("FigmaSize") and selectedInstance:GetAttribute("FigmaSize").Y or 100)
    )

    local Position = Vector2.new(
        ToNumber(data.Position and data.Position.X, selectedInstance:GetAttribute("FigmaPosition") and selectedInstance:GetAttribute("FigmaPosition").X or 0),
        ToNumber(data.Position and data.Position.Y, selectedInstance:GetAttribute("FigmaPosition") and selectedInstance:GetAttribute("FigmaPosition").Y or 0)
    )

    Utility.CreateUndoMarkerStart()

    local SettingAttributes = {}
    for SettingName, SettingValue in pairs(data.Settings or {}) do
        SettingAttributes[`FigmaSetting_{SettingName}`] = SettingValue
    end

    local SettingSeamProperties = {}
    for AttributeName, AttributeValue in pairs(SettingAttributes) do
        SettingSeamProperties[Seam.Attribute(AttributeName)] = AttributeValue
    end
    Seam.New(selectedInstance, SettingSeamProperties)

    if selectedInstance:IsA("ScreenGui") then
        Seam.New(selectedInstance, {
            Name = data.Name or selectedInstance.Name,
            [Seam.Attribute("FigmaSize")] = Size,
            [Seam.Attribute("FigmaPosition")] = Position,
        })

        Utility.CreateUndoMarkerEnd()
        return
    end

    if not selectedInstance:IsA("GuiObject") then
        Utility.CreateUndoMarkerEnd()
        return
    end
            
    local AnchorPoint = Vector2.new(
        ToNumber(data.AnchorPoint and data.AnchorPoint.X, selectedInstance.AnchorPoint.X),
        ToNumber(data.AnchorPoint and data.AnchorPoint.Y, selectedInstance.AnchorPoint.Y)
    )

    local Stroke = ToNumber(data.Stroke, selectedInstance:GetAttribute("FigmaStrokeThickness") or 0)
    local ShadowOffsettedSize, ShadowOffset = GetOffsettedSizeAndPositionFromShadow(data.Shadow)
    local ShadowOffsetFinal = ShadowOffsettedSize -- ShadowOffset / 2 + ShadowOffsettedSize
    local CorrectedSize = Size + Vector2.new(Stroke * 2, Stroke * 2) + ShadowOffsettedSize * 2 + ShadowOffset
    local CorrectedPosition = Position - Vector2.new(Stroke, Stroke) - ShadowOffsetFinal + ShadowOffset / 2
    local FinalSize = CorrectedSize
    local FinalPosition = CorrectedPosition
    

    Seam.New(selectedInstance, {
        [Seam.Attribute("FigmaSize")] = Size,
        [Seam.Attribute("FigmaPosition")] = Position,
        [Seam.Attribute("FigmaShadowOffset")] = ShadowOffset,
        [Seam.Attribute("FigmaShadowRadius")] = data.Shadow and data.Shadow.Radius or 0,
        [Seam.Attribute("FigmaShadowSpread")] = data.Shadow and data.Shadow.Spread or 0,
    })

    if selectedInstance.Parent:GetAttribute("FigmaStrokeThickness") then
        local ParentStrokeOffset = selectedInstance.Parent:GetAttribute("FigmaStrokeThickness") - Stroke
        FinalSize -= Vector2.new(ParentStrokeOffset, ParentStrokeOffset) * 2
        FinalPosition += Vector2.new(ParentStrokeOffset, ParentStrokeOffset)
    end

    if selectedInstance.Parent:GetAttribute("IsFigmaImportGroup") then
        FinalPosition -= selectedInstance.Parent:GetAttribute("FigmaPosition")
    end

    local ParentContextSize = GetContextualParentSizeForChild(selectedInstance)
    local ScaledSize = UDim2.fromScale(FinalSize.X / ParentContextSize.X, FinalSize.Y / ParentContextSize.Y)
    local ScaledPosition = Utility.ConvertToContextualScale(selectedInstance, FinalPosition)
            
    ScaledPosition += UDim2.fromScale(ScaledSize.X.Scale * AnchorPoint.X, ScaledSize.Y.Scale * AnchorPoint.Y)
    
    Seam.New(selectedInstance, {
        ClipsDescendants = data.Settings and data.Settings.ClipDescendants ~= nil and data.Settings.ClipDescendants or selectedInstance.ClipsDescendants,
        LayoutOrder = ToNumber(data.LayoutOrder, selectedInstance.LayoutOrder),
        Size = ScaledSize,
        Position = ScaledPosition,
        Name = data.Name or selectedInstance.Name,
        AnchorPoint = AnchorPoint,
        Rotation = ToNumber(data.Rotation, selectedInstance.Rotation),
    })

    local AspectRatio = if CorrectedSize.Y ~= 0 then CorrectedSize.X / CorrectedSize.Y else 1
    
    EnsureAspectRatioConstraint(
        selectedInstance,
        data.Settings and data.Settings.IsAspectRatioConstrained == true,
        AspectRatio
    )

    Utility.ApplyImage(selectedInstance, data.Image)

    Seam.New(selectedInstance, {
        [Seam.Attribute("FigmaStrokeThickness")] = Stroke,
    })

    Utility.CreateUndoMarkerEnd()
end

return Applicator