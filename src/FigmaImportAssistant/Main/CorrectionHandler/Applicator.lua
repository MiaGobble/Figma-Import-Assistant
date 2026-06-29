local Applicator = {}

local Utility = require(script.Parent.Parent.Utility)
local Packages = script.Parent.Parent.Parent.Packages
local Seam = require(Packages.Seam)

local function GetOffsettedSizeAndPositionFromShadow(Shadow)
    local SafeShadow = Shadow or {}
    local Offset = SafeShadow.Offset or Vector2.new(0, 0)
    local Radius = SafeShadow.Radius or 0
    local Spread = SafeShadow.Spread or 0
    local OffsettedSize = Vector2.new(Radius, Radius) + Vector2.new(Spread, Spread)

    return OffsettedSize, Offset
end

local function ToNumber(Value, Fallback)
    local Number = tonumber(Value)

    if Number == nil then
        return Fallback
    end

    return Number
end

local function EnsureAspectRatioConstraint(SelectedInstance : Instance, Enabled : boolean, AspectRatio : number)
    local Existing = SelectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint")

    if Enabled then
        if not Existing then
            Existing = Instance.new("UIAspectRatioConstraint")
            Existing.Parent = SelectedInstance
        end

        Existing.AspectRatio = AspectRatio
    elseif Existing then
        Existing:Destroy()
    end
end

local function ApplyAttributes(Object : Instance, Attributes : {[string] : any})
    local Count = 0

    for _ in pairs(Attributes) do
        Count += 1
    end

    if Count <= 1 then
        for AttributeName, AttributeValue in pairs(Attributes) do
            Object:SetAttribute(AttributeName, AttributeValue)
        end
        return
    end

    for AttributeName, AttributeValue in pairs(Attributes) do
        Seam.Attribute(AttributeName)(Object, AttributeValue)
    end
end

function Applicator:ApplyChangesFromData(SelectedInstance : Instance, Data : {[string] : any})
    if not SelectedInstance then
        return
    end

    local Size = Vector2.new(
        ToNumber(Data.Size and Data.Size.X, SelectedInstance:GetAttribute("FigmaSize") and SelectedInstance:GetAttribute("FigmaSize").X or 100),
        ToNumber(Data.Size and Data.Size.Y, SelectedInstance:GetAttribute("FigmaSize") and SelectedInstance:GetAttribute("FigmaSize").Y or 100)
    )

    local Position = Vector2.new(
        ToNumber(Data.Position and Data.Position.X, SelectedInstance:GetAttribute("FigmaPosition") and SelectedInstance:GetAttribute("FigmaPosition").X or 0),
        ToNumber(Data.Position and Data.Position.Y, SelectedInstance:GetAttribute("FigmaPosition") and SelectedInstance:GetAttribute("FigmaPosition").Y or 0)
    )

    Utility.CreateUndoMarkerStart()

    local SettingAttributes = {}
    for SettingName, SettingValue in Data.Settings or {} do
        SettingAttributes[`FigmaSetting_{SettingName}`] = SettingValue
    end
    ApplyAttributes(SelectedInstance, SettingAttributes)

    if SelectedInstance:IsA("ScreenGui") then
        SelectedInstance:SetAttribute("FigmaSize", Size)
        SelectedInstance:SetAttribute("FigmaPosition", Position)
        SelectedInstance.Name = Data.Name or SelectedInstance.Name
        Utility.CreateUndoMarkerEnd()
        return
    end

    if not SelectedInstance:IsA("GuiObject") then
        Utility.CreateUndoMarkerEnd()
        return
    end
            
    local AnchorPoint = Vector2.new(
        ToNumber(Data.AnchorPoint and Data.AnchorPoint.X, SelectedInstance.AnchorPoint.X),
        ToNumber(Data.AnchorPoint and Data.AnchorPoint.Y, SelectedInstance.AnchorPoint.Y)
    )

    local Stroke = ToNumber(Data.Stroke, SelectedInstance:GetAttribute("FigmaStrokeThickness") or 0)
    local ShadowOffsettedSize, ShadowOffset = GetOffsettedSizeAndPositionFromShadow(Data.Shadow)
    local ShadowOffsetFinal = ShadowOffsettedSize--ShadowOffset / 2 + ShadowOffsettedSize
    local CorrectedSize = Size + Vector2.new(Stroke * 2, Stroke * 2) + ShadowOffsettedSize * 2 + ShadowOffset
    local CorrectedPosition = Position - Vector2.new(Stroke, Stroke) - ShadowOffsetFinal + ShadowOffset / 2
    local FinalSize = CorrectedSize
    local FinalPosition = CorrectedPosition
    

    ApplyAttributes(SelectedInstance, {
        FigmaSize = Size,
        FigmaPosition = Position,
        FigmaShadowOffset = ShadowOffset,
        FigmaShadowRadius = Data.Shadow and Data.Shadow.Radius or 0,
        FigmaShadowSpread = Data.Shadow and Data.Shadow.Spread or 0,
    })

    if SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") then
        local ParentStrokeOffset = SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") - Stroke
        FinalSize -= Vector2.new(ParentStrokeOffset, ParentStrokeOffset) * 2
        FinalPosition += Vector2.new(ParentStrokeOffset, ParentStrokeOffset)
    end

    -- if SelectedInstance.Parent:GetAttribute("FigmaObliqueSize") then
    --     local Oblique = SelectedInstance.Parent:GetAttribute("FigmaObliqueSize") - Oblique
    --     FinalSize -= Vector2.new(0, Oblique)
    -- end

    if SelectedInstance.Parent:GetAttribute("IsFigmaImportGroup") then
        FinalPosition -= SelectedInstance.Parent:GetAttribute("FigmaPosition")
    end

    local ScaledSize = Utility.ConvertToContextualScale(SelectedInstance, FinalSize)
    local ScaledPosition = Utility.ConvertToContextualScale(SelectedInstance, FinalPosition)
            
    ScaledPosition += UDim2.fromScale(ScaledSize.X.Scale * AnchorPoint.X, ScaledSize.Y.Scale * AnchorPoint.Y)
    
    SelectedInstance.ClipsDescendants = Data.Settings and Data.Settings.ClipDescendants ~= nil and Data.Settings.ClipDescendants or SelectedInstance.ClipsDescendants
    SelectedInstance.Size = ScaledSize
    SelectedInstance.Position = ScaledPosition
    SelectedInstance.Name = Data.Name or SelectedInstance.Name
    SelectedInstance.AnchorPoint = AnchorPoint

    local AspectRatio = if CorrectedSize.Y ~= 0 then CorrectedSize.X / CorrectedSize.Y else 1
    EnsureAspectRatioConstraint(
        SelectedInstance,
        Data.Settings and Data.Settings.IsAspectRatioConstrained == true,
        AspectRatio
    )

    Utility.ApplyImage(SelectedInstance, Data.Image)

    ApplyAttributes(SelectedInstance, {
        FigmaStrokeThickness = Stroke,
    })
    --SelectedInstance:SetAttribute("FigmaObliqueSize", Oblique)

    Utility.CreateUndoMarkerEnd()
end

return Applicator