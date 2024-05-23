local Applicator = {}

local Packages = script.Parent.Parent.Parent.Packages
local Fusion = require(Packages.Fusion)
local Utility = require(script.Parent.Parent.Utility)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children

function Applicator:ApplyChangesFromData(SelectedInstance : Instance, Data : {})
    local Size = Vector2.new(Data.Size.X, Data.Size.Y)
            local Position = Vector2.new(Data.Position.X, Data.Position.Y)

            Utility.CreateUndoMarkerStart()

            if SelectedInstance:IsA("ScreenGui") then
                SelectedInstance:SetAttribute("FigmaSize", Size)
                SelectedInstance:SetAttribute("FigmaPosition", Position)
                SelectedInstance.Name = Data.Name
                return
            end
            
            local AnchorPoint = Vector2.new(Data.AnchorPoint.X or 0, Data.AnchorPoint.Y or 0)
            local Stroke = Data.Stroke
            local Oblique = Data.Oblique
            local CorrectedSize = Size + Vector2.new(Stroke * 2, Stroke * 2) + Vector2.new(0, Oblique)
            local CorrectedPosition = Position - Vector2.new(Stroke, Stroke) - Vector2.new(0, Oblique)
            local FinalSize = CorrectedSize
            local FinalPosition = CorrectedPosition

            SelectedInstance:SetAttribute("FigmaSize", Size)
            SelectedInstance:SetAttribute("FigmaPosition", Position)

            if SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") then
                local Stroke = SelectedInstance.Parent:GetAttribute("FigmaStrokeThickness") - Stroke
                FinalSize -= Vector2.new(Stroke, Stroke) * 2
                FinalPosition += Vector2.new(Stroke, Stroke)
            end

            if SelectedInstance.Parent:GetAttribute("FigmaObliqueSize") then
                local Oblique = SelectedInstance.Parent:GetAttribute("FigmaObliqueSize") - Oblique
                FinalSize -= Vector2.new(0, Oblique)
            end

            local ScaledSize = Utility.ConvertToContextualScale(SelectedInstance, FinalSize)
            local ScaledPosition = Utility.ConvertToContextualScale(SelectedInstance, FinalPosition)
            
            ScaledPosition += UDim2.fromScale(ScaledSize.X.Scale * AnchorPoint.X, ScaledSize.Y.Scale * AnchorPoint.Y)
        
            if SelectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint") then
                SelectedInstance:FindFirstChildOfClass("UIAspectRatioConstraint"):Destroy()
            end

            Hydrate(SelectedInstance) {
                Size = ScaledSize,
                Position = ScaledPosition,
                Name = Data.Name,
                AnchorPoint = AnchorPoint,

                [Children] = New "UIAspectRatioConstraint" {
                    AspectRatio = CorrectedSize.X / CorrectedSize.Y,
                }
            }

            Utility.ApplyImage(SelectedInstance, Data.Image)

            SelectedInstance:SetAttribute("FigmaStrokeThickness", Stroke)
            SelectedInstance:SetAttribute("FigmaObliqueSize", Oblique)

            Utility.CreateUndoMarkerEnd()
end

return Applicator