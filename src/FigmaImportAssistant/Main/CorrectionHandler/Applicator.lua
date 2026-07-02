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

local function ReadRelativeTransformComponents(data)
    local RelativeTransform = data.RelativeTransform

    if type(RelativeTransform) ~= "table" then
        return nil
    end

    local Row1 = RelativeTransform[1]
    local Row2 = RelativeTransform[2]

    if type(Row1) ~= "table" or type(Row2) ~= "table" then
        return nil
    end

    local A = tonumber(Row1[1])
    local C = tonumber(Row1[2])
    local X = tonumber(Row1[3])
    local B = tonumber(Row2[1])
    local D = tonumber(Row2[2])
    local Y = tonumber(Row2[3])

    if A == nil or B == nil or C == nil or D == nil or X == nil or Y == nil then
        return nil
    end

    return A, B, C, D, X, Y
end

local function RotateVector(vector : Vector2, rotationDegrees : number)
    if rotationDegrees == 0 then
        return vector
    end

    local radians = math.rad(rotationDegrees)
    local cosTheta = math.cos(radians)
    local sinTheta = math.sin(radians)

    -- Roblox GUI uses a Y-down screen space with clockwise-positive rotation.
    return Vector2.new(
        vector.X * cosTheta + vector.Y * sinTheta,
        -vector.X * sinTheta + vector.Y * cosTheta
    )
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
    

    Seam.New(selectedInstance, {
        [Seam.Attribute("FigmaSize")] = Size,
        [Seam.Attribute("FigmaPosition")] = Position,
        [Seam.Attribute("FigmaShadowOffset")] = ShadowOffset,
        [Seam.Attribute("FigmaShadowRadius")] = data.Shadow and data.Shadow.Radius or 0,
        [Seam.Attribute("FigmaShadowSpread")] = data.Shadow and data.Shadow.Spread or 0,
    })

    local UsesLegacyXYPosition = data.PositionSource ~= "relativeTransform"
    local GeometrySize = Size
    local GeometryPosition = Position

    if UsesLegacyXYPosition then
        GeometrySize = CorrectedSize
        GeometryPosition = CorrectedPosition

        if selectedInstance.Parent:GetAttribute("FigmaStrokeThickness") then
            local ParentStrokeOffset = selectedInstance.Parent:GetAttribute("FigmaStrokeThickness") - Stroke
            GeometrySize -= Vector2.new(ParentStrokeOffset, ParentStrokeOffset) * 2
            GeometryPosition += Vector2.new(ParentStrokeOffset, ParentStrokeOffset)
        end

        if selectedInstance.Parent:GetAttribute("IsFigmaImportGroup") then
            GeometryPosition -= selectedInstance.Parent:GetAttribute("FigmaPosition")
        end
    end

    local Rotation = ToNumber(data.Rotation, selectedInstance.Rotation)
    local FinalPositionWithAnchor = nil
    local A, B, C, D, X, Y = ReadRelativeTransformComponents(data)

    if data.PositionSource == "relativeTransform" and A ~= nil then
        local AnchorOffsetPixels = Vector2.new(GeometrySize.X * AnchorPoint.X, GeometrySize.Y * AnchorPoint.Y)

        FinalPositionWithAnchor = Vector2.new(
            X + A * AnchorOffsetPixels.X + C * AnchorOffsetPixels.Y,
            Y + B * AnchorOffsetPixels.X + D * AnchorOffsetPixels.Y
        )
    else
        local AnchorOffsetPixels = Vector2.new(GeometrySize.X * AnchorPoint.X, GeometrySize.Y * AnchorPoint.Y)
        FinalPositionWithAnchor = GeometryPosition + RotateVector(AnchorOffsetPixels, Rotation)
    end

    local ParentContextSize = GetContextualParentSizeForChild(selectedInstance)
    local ScaledSize = UDim2.fromScale(GeometrySize.X / ParentContextSize.X, GeometrySize.Y / ParentContextSize.Y)
    local ScaledPosition = Utility.ConvertToContextualScale(selectedInstance, FinalPositionWithAnchor)
    
    Seam.New(selectedInstance, {
        ClipsDescendants = data.Settings and data.Settings.ClipDescendants ~= nil and data.Settings.ClipDescendants or selectedInstance.ClipsDescendants,
        LayoutOrder = ToNumber(data.LayoutOrder, selectedInstance.LayoutOrder),
        Size = ScaledSize,
        Position = ScaledPosition,
        Name = data.Name or selectedInstance.Name,
        AnchorPoint = AnchorPoint,
        Rotation = Rotation,
    })

    local AspectRatio = if GeometrySize.Y ~= 0 then GeometrySize.X / GeometrySize.Y else 1
    
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