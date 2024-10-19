local Applicator = {}

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
local Utility = require(script.Parent.Parent.Utility)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children

local function GetOffsettedSizeAndPositionFromShadow(Shadow)
    local Offset = Shadow.Offset
    local Radius = Shadow.Radius
    local Spread = Shadow.Spread
    local OffsettedSize = Vector2.new(Radius, Radius) + Vector2.new(Spread, Spread)

    return OffsettedSize, Offset
end

function Applicator:ApplyChangesFromData(SelectedInstance : Instance, Data : {[string] : any})
    local Size = Vector2.new(Data.Size.X, Data.Size.Y)
    local Position = Vector2.new(Data.Position.X, Data.Position.Y)

    Utility.CreateUndoMarkerStart()

    for SettingName, SettingValue in Data.Settings do
        SelectedInstance:SetAttribute(`FigmaSetting_{SettingName}`, SettingValue)
    end

    if SelectedInstance:IsA("ScreenGui") then
        SelectedInstance:SetAttribute("FigmaSize", Size)
        SelectedInstance:SetAttribute("FigmaPosition", Position)
        SelectedInstance.Name = Data.Name
        Utility.CreateUndoMarkerEnd()
        return
    end
            
    local AnchorPoint = Vector2.new(Data.AnchorPoint.X or 0, Data.AnchorPoint.Y or 0)
    local Stroke = Data.Stroke
    local ShadowOffsettedSize, ShadowOffset = GetOffsettedSizeAndPositionFromShadow(Data.Shadow)
    local ShadowOffsetFinal = ShadowOffsettedSize--ShadowOffset / 2 + ShadowOffsettedSize
    local CorrectedSize = Size + Vector2.new(Stroke * 2, Stroke * 2) + ShadowOffsettedSize * 2 + ShadowOffset
    local CorrectedPosition = Position - Vector2.new(Stroke, Stroke) - ShadowOffsetFinal + ShadowOffset / 2
    local FinalSize = CorrectedSize
    local FinalPosition = CorrectedPosition
    

    SelectedInstance:SetAttribute("FigmaSize", Size)
    SelectedInstance:SetAttribute("FigmaPosition", Position)
    SelectedInstance:SetAttribute("FigmaShadowOffset", ShadowOffset)
    SelectedInstance:SetAttribute("FigmaShadowRadius", Data.Shadow.Radius)
    SelectedInstance:SetAttribute("FigmaShadowSpread", Data.Shadow.Spread)

    if SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") then
        local Stroke = SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") - Stroke
        FinalSize -= Vector2.new(Stroke, Stroke) * 2
        FinalPosition += Vector2.new(Stroke, Stroke)
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
        
    if SelectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint") then
        SelectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint"):Destroy()
    end

    SelectedInstance.ClipsDescendants = Data.Settings.ClipsDescendants

    local InstanceChildren = {}

    if Data.Settings.IsAspectRatioConstrained then
        table.insert(InstanceChildren, New "UIAspectRatioConstraint" {
            AspectRatio = CorrectedSize.X / CorrectedSize.Y,
        })
    end

    Hydrate(SelectedInstance) {
        Size = ScaledSize,
        Position = ScaledPosition,
        Name = Data.Name,
        AnchorPoint = AnchorPoint,
        [Children] = InstanceChildren
    }

    Utility.ApplyImage(SelectedInstance, Data.Image)

    SelectedInstance:SetAttribute("FigmaStrokeThickness", Stroke)
    --SelectedInstance:SetAttribute("FigmaObliqueSize", Oblique)

    Utility.CreateUndoMarkerEnd()
end

return Applicator