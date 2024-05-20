local CorrectionHandler = {}

local SelectionService = game:GetService("Selection")

local Interface = require(script.Parent.Interface)
local Utility = require(script.Parent.Utility)
local Fusion = require(script.Parent.Parent.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children

local SelectedInstance = nil

function CorrectionHandler:Init()
    Interface:OnApply(function(Data)
        if SelectedInstance then
            if SelectedInstance:IsA("ScreenGui") then
                SelectedInstance.Name = Data.Name
                return
            end

            local Size = Vector2.new(Data.Size.X, Data.Size.Y)
            local Position = Vector2.new(Data.Position.X, Data.Position.Y)
            local AnchorPoint = Vector2.new(Data.AnchorPoint.X, Data.AnchorPoint.Y)
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
                --FinalPosition += Vector2.new(0, SelectedInstance.Parent:GetAttribute("FigmaObliqueSize"))
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
        end
    end)

    SelectionService.SelectionChanged:Connect(function()
        local Selected = SelectionService:Get()
        local SelectedCount = Utility.GetDictionaryLength(Selected)

        if SelectedCount == 1 then
            SelectedInstance = Selected[1]
        else
            SelectedInstance = nil
        end

        if SelectedInstance and not SelectedInstance:IsA("GuiObject") and not SelectedInstance:IsA("ScreenGui") then
            SelectedInstance = nil
        end
        
        Interface:OnSelection(SelectedInstance)
    end)
end

return CorrectionHandler